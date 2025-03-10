local icons = require("icons")
local colors = require("colors")

local whitelist = { ["Spotify"] = true, ["Music"] = true, ["Cider"] = true, ["Arc"] = true, ["spotify_player"] = true }

local M = {}
local interupt = 1

sbar.add("event", "cava_toggle")

M.cava_watcher = sbar.add("item", "cava_watch", {
	width = 5,
})

M.media_cover = sbar.add("item", {
	position = "left",
	background = {
		image = {
			string = "media.artwork",
			scale = 0.85,
			-- corner_radius = 10,
		},
		color = colors.transparent,
		-- corner_radius = 10,
	},
	label = { drawing = false },
	icon = { drawing = false },
	drawing = false,
	updates = true,
	popup = {
		align = "center",
		horizontal = true,
	},
	padding_right = -2,
	padding_left = -0.5,
})

M.cava = sbar.add("item", "media_cava", {
	position = "left",
	icon = {
		drawing = false,
	},
	label = {
		drawing = true,
		width = "dynamic",
	},
	update_freq = 0,
	y_offset = -5,
	script = "~/.config/sketchybar/helpers/cava.sh",
})

M.media_artist = sbar.add("item", {
	position = "left",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	width = 0,
	icon = { drawing = false },
	label = {
		width = 0,
		font = { size = 9 },
		-- color = colors.with_alpha(colors.white, 0.6),
		color = colors.orange,
		max_chars = 18,
		y_offset = 6,
	},
})

M.media_title = sbar.add("item", {
	position = "left",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		-- color = colors.with_alpha(colors.white, 0.6),
		color = colors.orange,
		font = { size = 11 },
		width = 0,
		max_chars = 16,
		y_offset = -5,
	},
})

local inter = 0
local function animate_detail(detail)
	if not detail then
		inter = inter - 1
	end
	if inter > 0 and not detail then
		return
	end
	print(inter)
	sbar.animate("tanh", 30, function()
		M.media_artist:set({ label = { width = detail and "dynamic" or 0 } })
		M.media_title:set({ label = { width = detail and "dynamic" or 0 } })
		return
	end)
end

sbar.add("item", {
	position = "popup." .. M.media_cover.name,
	icon = { string = icons.media.back },
	label = { drawing = false },
	click_script = "nowplaying-cli previous",
})
sbar.add("item", {
	position = "popup." .. M.media_cover.name,
	icon = { string = icons.media.play_pause },
	label = { drawing = false },
	click_script = "nowplaying-cli togglePlayPause",
})
sbar.add("item", {
	position = "popup." .. M.media_cover.name,
	icon = { string = icons.media.forward },
	label = { drawing = false },
	click_script = "nowplaying-cli next",
})

M.cava_bracket = sbar.add("bracket", { M.media_cover.name, M.media_artist.name, M.media_title.name, M.cava.name }, {
	background = {
		color = colors.bg3,
		drawing = true,
	},
})

M.cava_watcher:subscribe({ "media_change" }, function(env)
	if whitelist[env.INFO.app] then
		local drawing = (env.INFO.state == "playing")
		if drawing or interupt == 1 then
			sbar.animate("tanh", 30, function()
				-- M.media_title:set({ drawing = drawing, label = env.INFO.title })
				-- M.media_artist:set({ drawing = drawing, label = env.INFO.artist })
				M.media_cover:set({ drawing = drawing })
				M.cava:set({
					label = { drawing = drawing },
					drawing = drawing,
				})
				M.cava_bracket:set({
					drawing = drawing,
				})
			end)
		end
		-- else
		-- 	M.media_title:set({ drawing = drawing, label = env.INFO.title })
		-- 	M.media_artist:set({ drawing = drawing, label = env.INFO.artist })
		-- 	M.media_cover:set({ drawing = drawing })
		-- 	if drawing then
		-- 		animate_detail(true)
		-- 		inter = inter + 1
		-- 		sbar.delay(5, animate_detail)
		-- 	else
		-- 		M.media_cover:set({ popup = { drawing = false } })
		-- 	end
	end
end)

M.cava_watcher:subscribe("cava_toggle", function(env)
	local drawing = (env.drawing == "true")
	if drawing then
		interupt = 1
		M.cava:set({
			drawing = drawing,
		})
	else
		interupt = 0
		M.cava:set({
			drawing = drawing,
		})
	end
end)

M.media_cover:subscribe("mouse.clicked", function(env)
	M.media_cover:set({ popup = { drawing = "toggle" } })
	-- M.media_title:set({ drawing = true, label = env.INFO.title })
	-- M.media_artist:set({ drawing = true, label = env.INFO.artist })
end)

M.media_cover:subscribe("mouse.exited.global", function(env)
	M.media_cover:set({ popup = { drawing = false } })
end)

-- M.media_cover:subscribe("mouse.entered", function(env)
-- 	inter = inter + 1
-- 	animate_detail(true)
-- end)
--
-- M.media_cover:subscribe("mouse.exited", function(env)
-- 	animate_detail(false)
-- end)
return M

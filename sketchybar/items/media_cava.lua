local icons = require("icons")
local colors = require("colors")

local whitelist = {
	["Spotify"] = true,
	["Music"] = true,
	["Cider"] = true,
	["Arc"] = true,
	["spotify_player"] = true,
	["Zen Browser"] = true,
}
local devicelist = { ["WH-1000XM5\n"] = false }

local M = {}
local interupt = 1

sbar.add("event", "cava_toggle")

M.cava_watcher = sbar.add("item", "cava_watch", {
	width = 5,
})

M.cava_media_cover = sbar.add("item", {
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
		-- height = 50,
		align = "center",
		horizontal = true,
	},
	padding_right = -2,
	padding_left = -0.5,
	display = "active",
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
	display = "active",
})

--
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
	scroll_texts = true,
	display = "active",
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
	scroll_texts = true,
	display = "active",
})

M.media_control_previous = sbar.add("item", {
	position = "popup." .. M.cava_media_cover.name,
	icon = { string = icons.media.back },
	label = { drawing = false },
	click_script = "nowplaying-cli previous",
})

M.media_control_toggleplaypause = sbar.add("item", {
	position = "popup." .. M.cava_media_cover.name,
	icon = { string = icons.media.play_pause },
	label = { drawing = false },
	click_script = "nowplaying-cli togglePlayPause",
})

M.media_control_next = sbar.add("item", {
	position = "popup." .. M.cava_media_cover.name,
	icon = { string = icons.media.forward },
	label = { drawing = false },
	click_script = "nowplaying-cli next",
})

M.cava_bracket = sbar.add(
	"bracket",
	{ M.cava_media_cover.name, M.cava.name, M.media_artist.name, M.media_title.name },
	{
		background = {
			color = colors.bg3,
			drawing = true,
			border_width = 0,
		},
	}
)

-- M.media_bracket = sbar.add("bracket", { M.pop_media_cover.name, M.media_artist.name, M.media_title.name }, {
-- 	background = {
-- 		height = 50,
-- 		color = colors.with_alpha(colors.bg3, 0.3),
-- 		border_color = colors.black,
-- 		border_width = 1,
-- 	},
-- })

local inter = 0
local function animate_detail(detail)
	if not detail then
		inter = inter - 1
	end
	if inter > 0 and not detail then
		return
	end

	sbar.animate("tanh", 30, function()
		M.media_artist:set({ label = { width = detail and "dynamic" or 0 } })
		M.media_title:set({ label = { width = detail and "dynamic" or 0 } })
		return
	end)
end

M.cava_watcher:subscribe({ "media_change" }, function(env)
	if whitelist[env.INFO.app] then
		local drawing = (env.INFO.state == "playing")
		M.cava_media_cover:set({ drawing = drawing })
		M.media_title:set({ label = { string = env.INFO.title } })
		M.media_artist:set({ label = env.INFO.artist })
		if interupt == 1 then
			M.cava:set({
				label = { drawing = drawing },
				drawing = drawing,
			})
			M.media_title:set({ drawing = false })
			M.media_artist:set({ drawing = false })
		else
			M.cava:set({
				label = { drawing = false },
				drawing = false,
			})
			M.media_title:set({ drawing = true, label = { string = env.INFO.title } })
			M.media_artist:set({ drawing = true, label = env.INFO.artist })

			M.cava_bracket:set({
				drawing = true,
			})
			if drawing then
				animate_detail(true)
				inter = inter + 1
				sbar.delay(5, animate_detail)
			else
				M.cava_media_cover:set({ popup = { drawing = false } })
			end
		end
		M.cava_bracket:set({
			drawing = drawing,
		})
	end
end)

M.cava_watcher:subscribe("cava_toggle", function(env)
	local drawing = (env.drawing == "true")
	if drawing then
		interupt = 1
		M.cava:set({
			drawing = drawing,
		})
		M.media_title:set({ drawing = false })
		M.media_artist:set({ drawing = false })
	else
		interupt = 0
		M.cava:set({
			drawing = drawing,
		})
		M.media_title:set({ drawing = true })
		M.media_artist:set({ drawing = true })
	end
end)

M.cava_media_cover:subscribe("mouse.clicked", function(env)
	M.cava_media_cover:set({ popup = { drawing = "toggle" } })
end)

M.cava_media_cover:subscribe("mouse.exited.global", function(env)
	M.cava_media_cover:set({ popup = { drawing = false } })
end)

M.cava_media_cover:subscribe("mouse.entered", function(env)
	inter = inter + 1
	animate_detail(true)
end)

M.cava_media_cover:subscribe("mouse.exited", function(env)
	animate_detail(false)
end)

return M

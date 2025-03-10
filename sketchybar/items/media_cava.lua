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

M.cava_bracket = sbar.add("bracket", { M.media_cover.name, M.cava.name }, {
	background = {
		color = colors.bg3,
		drawing = true,
	},
})

M.cava_watcher:subscribe({ "media_change" }, function(env)
	local drawing = (env.INFO.state == "playing")
	if drawing and interupt == 1 then
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
return M

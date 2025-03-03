local colors = require("colors")
local settings = require("settings")

local M = {}

sbar.add("item", {
	width = 10,
})

M.front_app = sbar.add("item", "front_app", {
	display = "active",
	position = "left",
	notch_offset = 10,
	y_offset = 20,
	icon = { drawing = false },
	label = {
		align = "center",
		padding_left = 0,
		padding_right = 0,
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
		-- color = colors.black,
		color = colors.front_app_color,
		max_chars = 7,
	},
	updates = true,
	scroll_texts = true,
})

M.front_app_bracket = sbar.add("bracket", {
	M.front_app.name,
}, {
	background = {
		color = colors.bg3,
		border_width = 0,
		height = 25,
		corner_radius = 20,
	},
})

sbar.add("item", {
	width = 5,
})

M.front_app:subscribe("front_app_switched", function(env)
	sbar.animate("circ", 30, function()
		M.front_app:set({ label = { string = env.INFO }, y_offset = 30 })
		M.front_app_bracket:set({ y_offset = 40 })
		M.front_app:set({ label = { string = env.INFO }, y_offset = 0 })
		M.front_app_bracket:set({ y_offset = 0 })
	end)
end)

return M

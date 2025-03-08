local colors = require("colors")
local settings = require("settings")

sbar.add("event", "aerospace_mode_trigger")

local M = {}

M.aerospace_mode = sbar.add("item", "aerospace_mode", {
	display = "active",
	position = "center",
	y_offset = 20,
	icon = { drawing = false },
	label = {
		align = "center",
		padding_left = 0,
		padding_right = 0,
		font = {
			style = settings.font.style_map["Black"],
			size = 14.0,
		},
		-- color = colors.black,
		color = colors.front_app_color,
		max_chars = 7,
	},
	updates = true,
	scroll_texts = true,
})

M.aerospace_mode_bracket = sbar.add("bracket", {
	M.aerospace_mode.name,
}, {
	background = {
		color = colors.bg3,
		border_width = 0,
		height = 25,
		corner_radius = 20,
	},
})

M.aerospace_mode:subscribe("aerospace_mode_trigger", function(env)
	print(env.MODE)
	sbar.animate("tanh", 40, function()
		M.aerospace_mode:set({ label = { string = env.MODE }, y_offset = 50 })
		M.aerospace_mode_bracket:set({ y_offset = 40 })
		M.aerospace_mode:set({ y_offset = -10 })
		M.aerospace_mode_bracket:set({ y_offset = -10 })
		M.aerospace_mode:set({ y_offset = 50 })
		M.aerospace_mode_bracket:set({ y_offset = 40 })
	end)
end)

return M

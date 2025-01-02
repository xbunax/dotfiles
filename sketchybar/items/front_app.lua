local colors = require("colors")
local settings = require("settings")

local M = {}
M.front_app = sbar.add("item", "front_app", {
	display = "active",
	position = "left",
	icon = { drawing = false },
	label = {
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
		color = colors.front_app_color,
		max_chars = 7,
	},
	updates = true,
	scroll_texts = true,
})

M.front_app:subscribe("front_app_switched", function(env)
	M.front_app:set({ label = { string = env.INFO } })
end)

return M

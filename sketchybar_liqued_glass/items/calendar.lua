local settings = require("settings")
local colors = require("colors")

local M = {}
-- Padding item required because of bracket

M.cal = sbar.add("item", {
	icon = {
		color = colors.white,
		-- color = 0xdef4deba,
		padding_left = 6,
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
	},
	label = {
		color = colors.white,
		padding_right = 10,
		width = 80,
		align = "right",
		font = { family = settings.font.numbers },
	},
	position = "right",
	update_freq = 1,
	padding_left = 1,
	padding_right = 1,
	background = {
		color = colors.transparent,
		border_color = colors.black,
		border_width = 0,
	},
})

-- M.cal_icon = sbar.add("item", { icon = { string = "􀉉", size = 12 }, position = "right", padding_right = -8 })
-- Double border for calendar using a single item bracket

-- Padding item required because of bracket
-- sbar.add("item", { position = "right", width = settings.group_paddings })

M.cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
	M.cal:set({ icon = os.date("%a. %d %b "), label = os.date("%H:%M:%S") })
end)

return M

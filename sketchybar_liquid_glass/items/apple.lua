local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Padding item required because of bracket

-- sbar.add("item", { position = "right", icon = { string = " " }, width = 10 })

local M = {}
M.apple = sbar.add("item", {
	icon = {
		font = { size = 18.0 },
		string = icons.apple,
		padding_right = 0,
		padding_left = 8,
		color = colors.orange,
	},
	label = { drawing = false },
	background = {
		border_width = 0, -- 透明，由外层 bracket 玻璃胶囊提供容器
	},
	padding_left = 3,
	padding_right = 0,
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

return M

local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local qq = require("items.widgets.qq")

local switch = sbar.add("item", "widgets.switch", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
			string = icons.switch.on,
		},
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 8,
	drawing = true,
})

switch:subscribe("mouse.clicked", function(env)
	qq:set({ icon = { drawing = false, update = true } })
end)

sbar.add("bracket", "widgets.switch.bracket", { switch.name }, {
	background = { color = colors.bg1 },
})
--
-- sbar.add("item", "widgets.switch.padding", {
-- 	position = "right",
-- 	width = settings.group_paddings,
-- })

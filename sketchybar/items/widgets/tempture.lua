local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local tempture = sbar.add("item", "widgets.tempture", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 3,
	popup = { align = "center" },
})

tempture:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("/Users/xbunax/.local/bin/smctemp -c", function(cpu_tempure)
		local icon = "􀇬"
		local label = "󰔄"

		tempture:set({
			icon = {
				string = icon,
				color = colors.white,
			},
			label = { string = cpu_tempure .. label },
		})
	end)
end)

sbar.add("bracket", "widgets.tempture.bracket", { tempture.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.tempture.padding", {
	position = "right",
	width = settings.group_paddings,
})

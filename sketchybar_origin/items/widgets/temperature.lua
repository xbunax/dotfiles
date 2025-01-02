local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local temperature = sbar.add("graph", "widgets.temperature", 42, {
	position = "right",
	graph = { color = colors.green },
	background = {
		height = 22,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = { string = "􀇬" },
	label = {
		string = "?? 󰔄",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		align = "right",
		padding_right = 0,
		width = 0,
		y_offset = 4,
	},
	update_freq = 2,
	padding_right = settings.paddings + 6,
})

temperature:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("/Users/xbunax/.local/bin/smctemp -c", function(cpu_tempure)
		-- local icon = "􀇬"
		-- local label = "?? 󰔄"

		local soc_tempure = tonumber(cpu_tempure)
		temperature:push({ soc_tempure / 100 })
		local color = colors.green
		if soc_tempure > 50 then
			if soc_tempure < 60 then
				color = colors.yellow
			elseif soc_tempure < 80 then
				color = colors.orange
			else
				color = colors.red
			end
		end
		temperature:set({
			-- icon = {
			-- 	string = icon,
			-- 	color = colors.white,
			-- },
			graph = { color = color },
			label = soc_tempure .. "󰔄",
		})
	end)
end)

sbar.add("bracket", "widgets.temperature.bracket", { temperature.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.temperature.padding", {
	position = "right",
	width = settings.group_paddings,
})

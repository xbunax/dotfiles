local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local M = {}

M.battery = sbar.add("item", "widgets.battery", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 19.0,
		},
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 120,
	popup = { align = "center" },
})

M.remaining_time = sbar.add("item", {
	position = "popup." .. M.battery.name,
	icon = {
		string = "Time remaining:",
		width = 100,
		align = "left",
	},
	label = {
		string = "??:??h",
		width = 100,
		align = "right",
	},
})

M.battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local label = "?"

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local color = colors.green
		local charging, _, _ = batt_info:find("AC Power")

		if charging then
			icon = icons.battery.charging
		else
			if found and charge > 80 then
				icon = icons.battery._100
			elseif found and charge > 60 then
				icon = icons.battery._75
			elseif found and charge > 40 then
				icon = icons.battery._50
			elseif found and charge > 20 then
				icon = icons.battery._25
				color = colors.orange
			else
				icon = icons.battery._0
				color = colors.red
			end
		end

		local lead = ""
		if found and charge < 10 then
			lead = "0"
		end

		M.battery:set({
			icon = {
				string = icon,
				color = color,
			},
			label = { string = lead .. label },
		})
	end)
end)

M.battery:subscribe("mouse.clicked", function(env)
	local drawing = M.battery:query().popup.drawing
	M.battery:set({ popup = { drawing = "toggle" } })

	if drawing == "off" then
		sbar.exec("pmset -g batt", function(batt_info)
			local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
			local label = found and remaining .. "h" or "No estimate"
			M.remaining_time:set({ label = label })
		end)
	end
end)

-- sbar.add("bracket", "widgets.battery.bracket", { M.battery.name }, {
-- 	background = {
-- 		-- color = colors.bg3,
-- 		-- color = colors.with_alpha(colors.bg1, colors.transparency),
-- 	},
-- })
--
-- sbar.add("item", "widgets.battery.padding", {
-- 	position = "right",
-- 	width = settings.group_paddings,
-- })

return M

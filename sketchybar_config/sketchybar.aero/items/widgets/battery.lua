-- local icons = require("icons_yabai")
-- local colors = require("colors")
local settings = require("config.settings")
local constants = require("constants")

local battery = sbar.add("item", constants.items.battery, {
	position = "right",
	icon = {
		font = {
			style = settings.fonts.styles.regular,
			size = 19.0,
		},
	},
	label = { font = { family = settings.fonts.numbers } },
	update_freq = 120,
	popup = { align = "center" },
})

local remaining_time = sbar.add("item", {
	position = "popup." .. battery.name,
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

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local label = "?"

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local color = settings.colors.green
		local charging, _, _ = batt_info:find("AC Power")

		if charging then
			icon = settings.icons.text.battery.charging
		else
			if found and charge > 80 then
				icon = settings.icons.text.battery._100
			elseif found and charge > 60 then
				icon = settings.icons.text.battery._75
			elseif found and charge > 40 then
				icon = settings.icons.text.battery._50
			elseif found and charge > 20 then
				icon = settings.icons.text.battery._25
				color = settings.colors.orange
			else
				icon = settings.icons.text.battery._0
				color = settings.colors.red
			end
		end

		local lead = ""
		if found and charge < 10 then
			lead = "0"
		end

		battery:set({
			icon = {
				string = icon,
				color = color,
			},
			label = { string = lead .. label },
		})
	end)
end)

battery:subscribe("mouse.clicked", function(env)
	local drawing = battery:query().popup.drawing
	battery:set({ popup = { drawing = "toggle" } })

	if drawing == "off" then
		sbar.exec("pmset -g batt", function(batt_info)
			local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
			local label = found and remaining .. "h" or "No estimate"
			remaining_time:set({ label = label })
		end)
	end
end)

sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
	background = { color = settings.colors.bg1 },
})

sbar.add("item", "widgets.battery.padding", {
	position = "right",
	width = 2,
})

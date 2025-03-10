local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

-- To get the SOC temperature, the command is
-- /Applications/Stats.app/Contents/Resources/smc list -t | grep "Tp2a" | awk '{print $2}'

--While the average (it seems wrong) is:
-- /Applications/Stats.app/Contents/Resources/smc list -t | grep "Tp.a" | awk '{sum += $2; count++} END {print sum/count}'
local M = {}

M.temp = sbar.add("graph", "widgets.temp", 42, {
	position = "right",
	graph = { color = colors.blue },
	background = {
		height = 22,
		color = { alpha = 0 },
		-- color = colors.with_alpha(colors.bg1, colors.transparency),
		border_color = { alpha = 0 },
		drawing = true,
	},
	--   icon = { string = icons.cpu },
	label = {
		string = icons.temperature._0 .. "  ??",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		align = "right",
		-- padding_left = 2,
		width = 0,
		y_offset = 4,
	},
	blur_radius = colors.blur_radius,
	padding_right = -3,
})

M.cpu = sbar.add("graph", "widgets.cpu", 42, {
	position = "right",
	graph = { color = colors.blue },
	background = {
		height = 22,
		color = { alpha = 0 },
		-- color = colors.with_alpha(colors.bg1, colors.transparency),
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = { string = icons.cpu },
	label = {
		string = icons.percent._0 .. "  ??%",
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
	padding_right = -6,
})

local function updateTemperature()
	sbar.exec("~/.local/bin/smctemp/smctemp -c", function(output)
		local temperature = tonumber(output)
		M.temp:push({ temperature / 130. })

		local color = colors.green

		local label_icon = icons.temperature._0
		--
		if temperature > 66 then
			label_icon = icons.temperature._66
		elseif temperature > 33 then
			label_icon = icons.temperature._33
		else
			label_icon = icons.temperature._0
		end
		if temperature > 50 then
			if temperature < 70 then
				color = colors.yellow
			elseif temperature < 80 then
				color = colors.orange
			else
				color = colors.red
			end
		end

		M.temp:set({
			graph = { color = color },
			label = label_icon .. " " .. temperature .. "°C",
		})
	end)
end

M.cpu:subscribe("cpu_update", function(env)
	--   -- Also available: env.user_load, env.sys_load
	local load = tonumber(env.total_load)
	-- print(load)
	M.cpu:push({ load / 100. })

	local color = colors.blue
	local label_icon = icons.percent._0
	--
	if load > 80 then
		label_icon = icons.percent._100
		color = colors.orange
	elseif load > 75 then
		label_icon = icons.percent._75
		color = colors.yellow
	elseif load > 50 then
		label_icon = icons.percent._50
	elseif load > 25 then
		label_icon = icons.percent._25
	else
		label_icon = icons.percent._0
	end

	if load > 30 then
		if load < 60 then
			color = colors.yellow
		elseif load < 80 then
			color = colors.orange
		else
			color = colors.red
		end
	end

	M.cpu:set({
		graph = { color = color },
		label = label_icon .. "  " .. env.total_load .. "%",
	})
	updateTemperature()
end)

M.cpu:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

-- Background around the cpu item
-- sbar.add("bracket", "widgets.cpu.bracket", { cpu.name, temp.name }, {
-- background = { color = colors.bg3 },

-- background = {
-- 	color = colors.with_alpha(colors.bg1, colors.transparency),
-- },
-- })

-- Background around the cpu item
sbar.add("item", "widgets.cpu.padding", {
	position = "right",
	width = settings.group_paddings,
})

return M

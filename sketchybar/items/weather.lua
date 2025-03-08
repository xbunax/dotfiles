local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local M = {}
M.forecast_items = {}
local location_script = "curl -x '' -s 'https://ipinfo.io/json' | grep '\"city\"' | awk -F: '{print $2}' | tr -d '\", '"

local popup_width = 200

local function get_location()
	local handle = io.popen(location_script)
	local result = handle:read("*a") -- 读取命令输出
	handle:close()
	return result:gsub("\n", "")
end

local function map_condition_to_icon(cond)
	local condition = cond:lower():match("^%s*(.-)%s*$")
	if condition == "sunny" then
		return icons.weather.sunny
	elseif condition == "cloudy" or condition == "overcast" then
		return icons.weather.cloudy
	elseif condition == "clear" then
		return icons.weather.clear
	elseif string.find(condition, "storm") or string.find(condition, "thunder") then
		return icons.weather.stormy
	elseif string.find(condition, "partly") then
		return icons.weather.partly
	elseif string.find(condition, "rain") or string.find(condition, "drizzle") then
		return icons.weather.rainy
	elseif string.find(condition, "snow") then
		return icons.weather.snowy
	elseif string.find(condition, "mist") or string.find(condition, "fog") then
		return icons.weather.foggy
	end
	return "?"
end
local location = get_location()
local forecast_script = string.format(
	[[
  curl -s 'wttr.in/%s?format=j1' \
  | jq -r '
      .weather[:5][] 
      | [.date, .maxtempC, .mintempC, .hourly[0].weatherDesc[0].value] 
      | @tsv
    '
]],
	location
)
local weather_script = string.format("curl 'wttr.in/%s?format=j1' | jq -r '.current_condition[].temp_C'", location)
local weather_icon_script =
	string.format("curl 'wttr.in/%s?format=j1' | jq -r '.current_condition[].weatherDesc[0].value'", location)

M.weather_icon = sbar.add("item", {
	position = "right",
	padding_left = -5,
	padding_right = -3,
	icon = {
		-- padding_right = 5,
		font = {
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
	},
	update_freq = 3600,
	popup = { align = "right" },
})

M.weather_location = sbar.add("item", {
	position = "popup." .. M.weather_icon.name,
	icon = {
		width = popup_width / 2,
		string = "Location 􀋑 :",
		font = {
			style = settings.font.style_map["Bold"],
		},
		align = "left",
	},
	label = {
		width = popup_width / 2,
		string = location,
		align = "right",
	},
	update_freq = 3600,
	-- align = "center",
})

M.weather_cuurent_temp = sbar.add("item", {
	position = "popup." .. M.weather_icon.name,
	icon = {
		width = popup_width / 2,
		string = "Current 􂬮:",
		font = {
			style = settings.font.style_map["Bold"],
		},
		align = "left",
	},
	label = {
		width = popup_width / 2,
		align = "right",
		font = { family = settings.font.family },
	},
	update_freq = 3600,
	-- align = "center",
})

M.weather_icon:subscribe({ "routine", "forced", "system_woke" }, function()
	sbar.exec(weather_icon_script, function(weather_condition)
		local weather_icon = map_condition_to_icon(weather_condition)
		-- local temp = weather_condition:match("(%+?%-?%d+°C)")
		M.weather_icon:set({
			icon = { string = weather_icon },
		})
	end)
end)

local function weather_collapse_details()
	local drawing = M.weather_icon:query().popup.drawing == "on"
	if not drawing then
		return
	end
	M.weather_icon:set({ popup = { drawing = false } })
	sbar.remove("/weather.item\\.*/")
end

M.weather_icon:subscribe("mouse.clicked", function(env)
	-- local drawing = M.weather_icon:query().popup.drawing
	-- M.weather_icon:set({ popup = { drawing = "toggle" } })

	local counter = 0
	local should_draw = M.weather_icon:query().popup.drawing == "off"
	print(should_draw)
	if should_draw then
		M.weather_icon:set({ popup = { drawing = true } })
		sbar.exec(weather_script, function(weather_condition)
			local temp = weather_condition
			M.weather_cuurent_temp:set({ label = { string = temp .. "󰔄" } })

			sbar.exec(forecast_script, function(forecast_data)
				if not forecast_data or forecast_data == "" then
					M.weather_forecast:set({
						label = { string = "无法获取未来天气" },
					})
					return
				end

				local lines = {}
				for line in forecast_data:gmatch("[^\r\n]+") do
					table.insert(lines, line)
				end

				for _, l in ipairs(lines) do
					local date, maxT, minT, desc = l:match("([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+(.+)")

					local icon_str = map_condition_to_icon(desc)
					local forecast_str = string.format("%s %s~%s°C", icon_str, maxT, minT)

					local item = sbar.add("item", "weather.item" .. counter, {
						position = "popup." .. M.weather_icon.name,
						icon = {
							width = popup_width / 2,
							string = date .. ":",
							align = "left",
						},
						label = {
							font = { family = settings.font.family },
							string = forecast_str,
							align = "right",
							width = popup_width / 2,
						},
						-- align = "center",
						drawing = "on",
					})
					counter = counter + 1
				end
			end)
		end)
	else
		weather_collapse_details()
	end
end)

return M

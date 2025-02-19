local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local M = {}
M.forecast_items = {}
local location_script = "curl -x '' -s 'https://ipinfo.io/json' | grep '\"city\"' | awk -F: '{print $2}' | tr -d '\", '"

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
		width = 110,
		string = "Location 􀋑 :",
		font = {
			style = settings.font.style_map["Bold"],
		},
		align = "left",
	},
	label = {
		string = location,
		align = "right",
	},
	update_freq = 3600,
	-- align = "center",
})

M.weather_cuurent_temp = sbar.add("item", {
	position = "popup." .. M.weather_icon.name,
	icon = {
		width = 110,
		string = "Current 􂬮 :",
		font = {
			style = settings.font.style_map["Bold"],
		},
		align = "left",
	},
	label = {
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

M.weather_icon:subscribe("mouse.clicked", function(env)
	local drawing = M.weather_icon:query().popup.drawing
	M.weather_icon:set({ popup = { drawing = "toggle" } })

	if drawing == "off" then
		sbar.exec(weather_script, function(weather_condition)
			local temp = weather_condition
			M.weather_cuurent_temp:set({ label = { string = temp .. "°C" } })

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

				-- 获取当前日期
				local current_date = os.date("%Y-%m-%d")

				for _, l in ipairs(lines) do
					local date, maxT, minT, desc = l:match("([^\t]+)\t+([^\t]+)\t+([^\t]+)\t+(.+)")
					if date and maxT and minT and desc then
						-- 删除早于当前日期的 item
						for existing_date, item in pairs(M.forecast_items) do
							if existing_date < current_date then
								print(existing_date)
								item:remove()
								M.forecast_items[existing_date] = nil
							end
						end

						-- 如果当日 item 没有创建过，才创建新的 item
						if not M.forecast_items[date] then
							local icon_str = map_condition_to_icon(desc)
							local forecast_str = string.format("%s %s~%s°C", icon_str, maxT, minT)

							-- 创建并记录 item
							local item = sbar.add("item", {
								position = "popup." .. M.weather_icon.name,
								width = 110,
								icon = {
									string = date .. ":",
									align = "left",
								},
								label = {
									font = { family = settings.font.family },
									string = forecast_str,
									align = "right",
								},
								-- align = "center",
								drawing = "on",
							})

							M.forecast_items[date] = item
						else
							local icon_str = map_condition_to_icon(desc)
							local forecast_str = string.format("%s %s~%s°C", icon_str, maxT, minT)
							M.forecast_items[date]:set({
								label = { string = forecast_str },
							})
						end
					end
				end
			end)
		end)
	end
end)

return M

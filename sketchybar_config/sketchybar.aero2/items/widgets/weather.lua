--only for DWD (Deutscher Wetterdienst)

local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 300

local weather_icon = sbar.add("item", "widgets.weather.icon", {
	position = "right",
	icon = {
		font = {
			family = settings.font.weather,
			size = 16.0,
		},
		string = "􀌏",
	},
	label = {
		font = {
			family = settings.font.numbers,
		},
		string = "...°",
	},
	update_freq = 180,
})

local weather_info = sbar.add("bracket", "widgets.weather.info", {
	weather_icon.name,
}, {
	background = {
		color = colors.bg2,
		border_color = colors.bg1,
		border_width = 2,
	},
	popup = { align = "center", height = 30 }
})


local function get_icon(icon)
	local icons_map = {
		["clear-day"] = "", -- Sunny, Clear
		["clear-night"] = "", -- Clear night
		["partly-cloudy-day"] = "", -- Partly cloudy
		["partly-cloudy-night"] = "", -- Partly cloudy night
		["cloudy"] = "", -- Cloudy
		["fog"] = "", -- Fog
		["wind"] = "", -- Wind
		["rain"] = "", -- Rains
		["sleet"] = "", -- Sleet
		["snow"] = "", -- Snow
		["hail"] = "", -- Hail
		["thunderstorm"] = "", -- Thunderstorm
	}

	local mapped_icon = icons_map[icon]
	return mapped_icon or ""
end

local conditions_translation = {
	["clear-day"] = "Klarer Tag",
	["clear-night"] = "Klarer Nacht",
	["partly-cloudy-day"] = "Teilweise bewölkt",
	["partly-cloudy-night"] = "Teilweise bewölkt",
	["cloudy"] = "Stark Bewölkt",
	["dry"] = "Trocken",
	["fog"] = "Neblig",
	["wind"] = "Stürmisch",
	["rain"] = "Regnerisch",
	["sleet"] = "Schneeregen",
	["snow"] = "Schnee",
	["hail"] = "Hagel",
	["thunderstorm"] = "Gewitter"
}

local function translate_condition(condition)
	return conditions_translation[condition] or condition
end

local function fetch_weather_data(callback)
	local command = "~/.scripts/akt_weather.sh"
	sbar.exec(command, function(output)
		local temperature = string.match(output, "Temperature:%s*(%d+%.?%d*)°C")
		local icon = string.match(output, "Icon:%s*([%w%-]+)")

		if temperature and icon then
			callback(temperature, icon)
		else
			print("Weather data extraction failed")
		end
	end)
end


weather_icon:subscribe({ "routine", "forced", "system_woke" }, function(env)
	fetch_weather_data(function(temperature, icon)
		if temperature and icon then
			local rounded_temperature = math.floor(temperature + 0.5)

			weather_icon:set({
				label = {
					string = rounded_temperature .. "°",
					color = colors.dirty_white,
				},
				icon = {
					string = get_icon(icon),
					color = colors.dirty_white,
				},
			})
		end
	end)
end)


sbar.add("item", "widgets.weather_icon.padding", {
	position = "right",
	width = settings.group_paddings
})


local station_name = sbar.add("item", {
	position = "popup." .. weather_info.name,
	icon = {
		font = {
			style = settings.font.style_map["Bold"]
		},
		string = "􀌏",
	},
	width = popup_width,
	align = "center",
	label = {
		font = {
			size = 15,
			style = settings.font.style_map["Bold"]
		},
		max_chars = 30,
		string = "????????????",
	},
	background = {
		height = 2,
		color = colors.grey,
		y_offset = -15
	}
})

local temperature = sbar.add("item", {
	position = "popup." .. weather_info.name,
	icon = {
		align = "left",
		string = "Temperatur:",
		width = popup_width / 2,
	},
	label = {
		string = "???",
		width = popup_width / 2,
		align = "right",
	}
})

local condition = sbar.add("item", {
	position = "popup." .. weather_info.name,
	icon = {
		align = "left",
		string = "Wetterlage:",
		width = popup_width / 2,
	},
	label = {
		string = "???",
		width = popup_width / 2,
		align = "right",
	}
})

local windspeed = sbar.add("item", {
	position = "popup." .. weather_info.name,
	icon = {
		align = "left",
		string = "Windgeschwindigkeit:",
		width = popup_width / 2,
	},
	label = {
		string = "???",
		width = popup_width / 2,
		align = "right",
	}
})

local cloudcover = sbar.add("item", {
	position = "popup." .. weather_info.name,
	icon = {
		align = "left",
		string = "Bewölkung:",
		width = popup_width / 2,
	},
	label = {
		string = "???",
		width = popup_width / 2,
		align = "right",
	}
})

local visibility = sbar.add("item", {
	position = "popup." .. weather_info.name,
	icon = {
		align = "left",
		string = "Sichtweite:",
		width = popup_width / 2,
	},
	label = {
		string = "???",
		width = popup_width / 2,
		align = "right",
	}
})

local function hide_details()
	weather_info:set({ popup = { drawing = false } })
end

local function toggle_details()
	local should_draw = weather_info:query().popup.drawing == "off"
	if should_draw then
		weather_info:set({ popup = { drawing = true } })
		sbar.exec("~/.scripts/akt_weather.sh", function(result)
			local popup_temperature = string.match(result, "Temperature:%s*(%d+%.?%d*)°C")
			local popup_station_name = string.match(result, "Station Name:%s*(.-)\n")
			local popup_condition = string.match(result, "Condition:%s*(.-)\n")
			local popup_icon = string.match(result, "Icon:%s*(.-)\n")
			local popup_wind_speed = string.match(result, "Wind Speed:%s*(.-)\n")
			local popup_cloud_cover = string.match(result, "Cloud Cover:%s*(.-)\n")
			local popup_visibility = string.match(result, "Visibility:%s*(.-)\n")

			popup_condition = translate_condition(popup_condition)

			local visibility_km = tonumber(popup_visibility) / 1000

			station_name:set({
				label = popup_station_name,
				icon = {
					string = get_icon(popup_icon),
					font = {
						family = settings.font.weather,
						size = 16.0,
					},
				}
			})

			temperature:set({ label = popup_temperature .. " °C" })
			condition:set({ label = popup_condition })
			windspeed:set({ label = popup_wind_speed .. " km/h" })
			cloudcover:set({ label = popup_cloud_cover .. " %" })
			visibility:set({ label = string.format("%.1f km", visibility_km) })
		end)
	else
		hide_details()
	end
end


weather_icon:subscribe("mouse.clicked", toggle_details)
weather_info:subscribe("mouse.clicked", toggle_details)

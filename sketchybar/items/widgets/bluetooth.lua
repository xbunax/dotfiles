local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local B = {}

local get_connected_bluetooth = [[
blueutil --connected | jq -Rn '
[inputs
 | capture("(?<addr>address: [^,]+), (?<rest>.*)")
 | ( .rest | split(",(?![^()]*\\)) *"; "g") ) as $parts
 | reduce $parts[] as $item (
     { address: .addr | sub("^address: "; "") };
     . as $acc
     | ( $item | gsub("^ +"; "") ) as $item
     | if $item == "not connected" then $acc | .connected = false
       elif $item == "connected" or ($item | test("^connected ")) then $acc | .connected = true
       elif $item == "not favourite" then $acc | .favourite = false
       elif $item == "paired" then $acc | .paired = true
       elif $item | contains(": ") then
           ($item | split(": ") | .[0] as $key | .[1] as $value
             | if $key == "name" then $acc | .name = ($value | gsub("\""; ""))
               elif $key == "recent access date" then $acc | .recent_access_date = $value
               else $acc
               end)
       else $acc
       end
   )
 | {
     address,
     connected: (.connected // false),
     favourite: (.favourite // false),
     paired: (.paired // false),
     name: (.name // ""),
     recent_access_date: (.recent_access_date // "")
   }
]'
]]

local get_paired_bluetooth = [[
blueutil --paired | jq -Rn '
[inputs
 | capture("(?<addr>address: [^,]+), (?<rest>.*)")
 | ( .rest | split(",(?![^()]*\\)) *"; "g") ) as $parts
 | reduce $parts[] as $item (
     { address: .addr | sub("^address: "; "") };
     . as $acc
     | ( $item | gsub("^ +"; "") ) as $item
     | if $item == "not connected" then $acc | .connected = false
       elif $item == "connected" or ($item | test("^connected ")) then $acc | .connected = true
       elif $item == "not favourite" then $acc | .favourite = false
       elif $item == "paired" then $acc | .paired = true
       elif $item | contains(": ") then
           ($item | split(": ") | .[0] as $key | .[1] as $value
             | if $key == "name" then $acc | .name = ($value | gsub("\""; ""))
               elif $key == "recent access date" then $acc | .recent_access_date = $value
               else $acc
               end)
       else $acc
       end
   )
 | {
     address,
     connected: (.connected // false),
     favourite: (.favourite // false),
     paired: (.paired // false),
     name: (.name // ""),
     recent_access_date: (.recent_access_date // "")
   }
]'
]]

local popup_width = 250

local B = {}
B.bluetooth_icon = sbar.add("item", {
	position = "right",
	padding_left = 5,
	padding_right = -10,
	icon = {
		string = "󰂯",
		font = { style = settings.font.style_map["Bold"], size = 15.0 },
	},
	popup = {
		align = "center",
		drawing = true, -- 启用动态内容支持
	},
})

local bluetooth_bracket = sbar.add("bracket", "widgets.bluetooth.bracket", {
	B.bluetooth_icon.name,
}, {
	popup = {
		align = "center",
		-- drawing = "off",
	},
})

local function bluetooth_collapse_details()
	local drawing = bluetooth_bracket:query().popup.drawing == "on"
	if not drawing then
		return
	end
	bluetooth_bracket:set({ popup = { drawing = false } })
	sbar.remove("/bluetooth.device\\.*/")
end

local bluetooth_switch = sbar.add("item", {
	position = "popup." .. bluetooth_bracket.name,
	label = { string = "off   " .. "󰔡" .. "   on", size = 30 },
	width = popup_width,
	align = "center",
	popup = {
		drawing = true,
	},
	click_script = "if [ $(blueutil -p) -eq 1 ]; then blueutil -p 0; else blueutil -p 1; fi",
})

bluetooth_switch:subscribe("mouse.clicked", function()
	sbar.exec("blueutil -p", function(bluetooth_state)
		if tonumber(bluetooth_state) == 1 then
			bluetooth_switch:set({ label = { string = "off   " .. "󰔡" .. "   on" } })
		else
			bluetooth_switch:set({ label = { string = "off   " .. "󰨙" .. "   on" } })
		end
	end)
end)

local function isInList(list, element)
	for _, v in ipairs(list) do
		if v == element then
			return true
		end
	end
	return false
end

local function bluetooth_deivce_list()
	local should_draw = bluetooth_bracket:query().popup.drawing == "off"
	local connected_devices_list = {}
	if should_draw then
		bluetooth_bracket:set({ popup = { drawing = true } })
		sbar.exec(get_paired_bluetooth, function(paired_bluetooth)
			sbar.exec(get_connected_bluetooth, function(connected_bluetooth)
				for _, connected_device in ipairs(connected_bluetooth) do
					connected_devices_list[#connected_devices_list + 1] = connected_device.address
				end

				for i, device in ipairs(paired_bluetooth) do
					local color = colors.grey
					if isInList(connected_devices_list, device.address) then
						print(true)
						color = colors.white
					end
					-- print(device.address)
					sbar.add("item", "bluetooth.device." .. i, {
						position = "popup." .. bluetooth_bracket.name,
						label = { string = device.name, color = color },
						width = popup_width,
						align = "center",
						click_script = "if [ $(blueutil --is-connected "
							.. device.address
							.. ") -eq 1 ]; then blueutil --disconnect "
							.. device.address
							.. "; else blueutil --connect "
							.. device.address
							-- .. " && sketchybar --set /bluetooth.device\\.*/ label.color="
							-- .. colors.white
							.. "; fi",
						-- .. " && sketchybar --set /bluetooth.device\\.*/ label.color="
						-- .. colors.grey
						-- .. " --set $NAME label.color="
						-- .. colors.white,
					})
				end
			end)
		end)
	else
		bluetooth_collapse_details()
	end
end

B.bluetooth_icon:subscribe("mouse.clicked", bluetooth_deivce_list)
B.bluetooth_icon:subscribe("mouse.clicked", bluetooth_deivce_list)
-- B.bluetooth_icon:subscribe("mouse.clicked", bluetooth_deivce_list)
-- B.bluetooth_icon:subscribe("mouse.clicked", bluetooth_deivce_list)

return B

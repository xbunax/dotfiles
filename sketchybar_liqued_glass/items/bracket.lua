local battery = require("items.widgets.battery")
local volume = require("items.widgets.volume")
-- local wechat_and_qq = require("items.widgets.wechat_and_qq")
-- local dingtalk = require("items.widgets.dingtalk")
local wifi = require("items.widgets.wifi")
local bluetooth = require("items.widgets.bluetooth")
local cpu_and_temp = require("items.widgets.cpu_and_temp")
local weather = require("items.weather")
-- local workspaces = require("items.spaces_aero")
-- local workspaces = require("items.spaces_yabai_dev")
local workspaces = require("items.spaces_aero_dev")
-- local workspaces = require("items.spaces")
-- local workspaces = require("items.spaces_flash_dev")
local apple = require("items.apple")
local cal = require("items.calendar")
-- local media = require("items.media")
-- local front_app = require("items.front_app")

local colors = require("colors")

-- 右侧外层大玻璃胶囊（包裹所有右侧 widgets）
local glass_capsule = {
	color = colors.bg3,        -- 10% 白色：主玻璃底
	border_color = colors.bg2, -- 22% 白色：玻璃边缘高光
	border_width = 1,
	height = 30,
	corner_radius = 12,
}

sbar.add("bracket", {
	cpu_and_temp.cpu.name,
	cpu_and_temp.temp.name,
	wifi.wifi.name,
	wifi.wifi_up.name,
	wifi.wifi_down.name,
	volume.volume_icon.name,
	volume.volume_percent.name,
	bluetooth.bluetooth_icon.name,
	-- dingtalk.Dingtalk.name,
	-- wechat_and_qq.wechat.name,
	-- wechat_and_qq.qq.name,
	cal.cal.name,
	weather.weather_icon.name,
	battery.battery.name,
}, { background = glass_capsule })

-- 右侧内层嵌套子胶囊（bt/vol/dt/cal/weather：信息控制类）
-- 稍深一点，形成视觉层次感
sbar.add("bracket", {
	bluetooth.bluetooth_icon.name,
	volume.volume_icon.name,
	volume.volume_percent.name,
	-- dingtalk.Dingtalk.name,
	-- wechat_and_qq.wechat.name,
	-- wechat_and_qq.qq.name,
	cal.cal.name,
	weather.weather_icon.name,
}, {
	background = {
		color = colors.bg1,        -- 12% 白色：内层更深一点
		border_color = colors.bg2,
		border_width = 1,
		height = 26,
		corner_radius = 9,
	},
})

-- 左侧玻璃胶囊（Apple 图标 + 工作区）
sbar.add("bracket", {
	apple.apple.name,
	workspaces[1].name,
	workspaces[2].name,
	workspaces[3].name,
	workspaces[4].name,
	workspaces[5].name,
	workspaces[6].name,
	workspaces[7].name,
	workspaces[8].name,
	workspaces[9].name,
	workspaces[10].name,
	-- media.media_cover.name,
	-- media.media_artist.name,
	-- media.media_title.name,
	-- front_app.front_app.name,
}, { background = glass_capsule })

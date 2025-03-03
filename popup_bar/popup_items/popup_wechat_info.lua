local colors = require("colors")
local settings = require("settings")
local icons_map = require("helpers.app_icons")

local M = {}

sbar.add("event", "wechat_notify_trigger")

M.wechat_info = sbar.add("item", "wechat_popup", {
	display = "active",
	position = "center",
	y_offset = 20,
	icon = {
		string = icons_map["微信"],
		font = "sketchybar-app-font:Regular:19.0",
		color = colors.green,
	},
	label = {
		string = "WeChat",
		align = "center",
		padding_left = 0,
		padding_right = 0,
		font = {
			style = settings.font.style_map["Black"],
			size = 14.0,
		},
		color = colors.green,
		-- color = colors.black,
		-- color = colors.front_app_color,
	},
	update_freq = 5,
	-- click_script = "open -a 'WeChat'",
	-- scroll_texts = true,
})

M.wechat_bracket = sbar.add("bracket", {
	M.wechat_info.name,
}, {
	background = {
		color = colors.bg3,
		border_width = 0,
		height = 25,
		corner_radius = 20,
	},
})

M.wechat_info:subscribe("wechat_notify_trigger", function(env)
	if env.POPUP == "true" then
		sbar.animate("tanh", 35, function()
			M.wechat_info:set({ y_offset = 50 })
			M.wechat_bracket:set({ y_offset = 50 })
			M.wechat_info:set({ y_offset = -10, drawing = true })
			M.wechat_bracket:set({ y_offset = -10, drawing = true })
			M.wechat_info:set({ y_offset = 50 })
			M.wechat_bracket:set({ y_offset = 50 })
		end)
	end
end)

-- M.wechat_info:subscribe("system_woke", function(env)
-- 	sbar.animate("tanh", 35, function()
-- 		M.wechat_info:set({ y_offset = 50 })
-- 		M.wechat_bracket:set({ y_offset = 50 })
-- 		M.wechat_info:set({ y_offset = -10, drawing = true })
-- 		M.wechat_bracket:set({ y_offset = -10, drawing = true })
-- 		M.wechat_info:set({ y_offset = 50 })
-- 		M.wechat_bracket:set({ y_offset = 50 })
-- 	end)
-- end)

return M

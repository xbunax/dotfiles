local icons = require("icons")
local icons_map = require("helpers.app_icons")
local colors = require("colors")
local settings = require("settings")

local M = {}

M.qq = sbar.add("item", "widgets.qq", {
	position = "right",
	icon = {
		font = "sketchybar-app-font:Regular:16.0",
		-- color = colors.black,
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 5,
	-- drawing = true,
})

M.wechat = sbar.add("item", "widgets.wechat", {
	position = "right",
	icon = {
		font = "sketchybar-app-font:Regular:19.0",
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 5,
})

M.wechat:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("lsappinfo -all list | grep wechat", function(wechat_notify)
		-- local icon = "󰘑"
		local icon = icons_map["微信"]
		local label = ""

		local notify_num = wechat_notify:match('"StatusLabel"=%{ "label"="?(.-)"? %}')

		if notify_num == nil or notify_num == "" then
			M.wechat:set({
				icon = {
					string = icon,
					color = colors.white,
				},
				label = { drawing = false },
			})
		else
			M.wechat:set({
				icon = {
					string = icon,
					color = colors.white,
				},
				label = { string = notify_num .. label, drawing = true },
			})
		end
	end)
end)

M.qq:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("lsappinfo -all list | grep qq", function(qq_notify)
		-- local icon = "󰘅"
		local icon = icons_map["QQ"]
		local label = ""

		local notify_num = qq_notify:match('"StatusLabel"=%{ "label"="?(.-)"? %}')

		if notify_num == nil or notify_num == "" then
			M.qq:set({
				icon = {
					string = icon,
					color = colors.white,
				},
				label = { drawing = false },
			})
		else
			M.qq:set({
				icon = {
					string = icon,
					color = colors.white,
					drawing = true,
				},
				label = { string = notify_num .. label, drawing = true },
			})
		end
	end)
end)

M.qq:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'QQ'")
end)
M.wechat:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'WeChat'")
end)

return M

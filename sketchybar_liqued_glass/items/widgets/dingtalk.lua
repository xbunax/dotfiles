local icons = require("icons")
local icons_map = require("helpers.app_icons")
local colors = require("colors")
local settings = require("settings")

local M = {}

M.Dingtalk = sbar.add("item", "widgets.dingtalk", {
	position = "right",
	icon = {
		font = "sketchybar-app-font:Regular:16.0",
		-- color = colors.black,
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 5,
	-- drawing = true,
})

M.Dingtalk:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("lsappinfo -all list | grep dingtalk", function(dingtalk_notify)
		-- local icon = "󰘅"
		local icon = icons_map["DingTalk"]
		local label = ""

		local notify_num = dingtalk_notify:match('"StatusLabel"=%{ "label"="?(.-)"? %}')

		if notify_num == nil or notify_num == "" or notify_num == "kCFNULL" then
			M.Dingtalk:set({
				icon = {
					string = icon,
					color = colors.white,
				},
				label = { drawing = false },
			})
		else
			M.Dingtalk:set({
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


M.Dingtalk:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Dingtalk'")
end)

return M

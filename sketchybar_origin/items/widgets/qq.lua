-- local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local qq = sbar.add("item", "widgets.qq", {
	position = "right",
	icon = {
		font = "sketchybar-app-font:Regular:16.0",
		-- color = colors.black,
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 5,
	drawing = true,
})

qq:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("lsappinfo -all list | grep qq", function(qq_notify)
		-- local icon = "󰘅"
		local icon = app_icons["QQ"]
		local label = ""

		local notify_num = qq_notify:match('"StatusLabel"=%{ "label"="?(.-)"? %}')

		if notify_num == nil or notify_num == "" then
			qq:set({
				icon = {
					string = icon,
					color = colors.white,
				},
				label = { drawing = false },
			})
		else
			qq:set({
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

qq:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'QQ'")
end)

sbar.add("bracket", "widgets.qq.bracket", { qq.name }, {
	background = { color = colors.bg3 },
})

sbar.add("item", "widgets.qq.padding", {
	position = "right",
	width = settings.group_paddings,
})

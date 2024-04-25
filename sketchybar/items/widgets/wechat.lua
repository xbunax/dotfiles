local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local wechat = sbar.add("item", "widgets.wechat", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 19.0,
		},
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 8,
})

wechat:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("lsappinfo -all list | grep wechat", function(wechat_notify)
		local icon = "󰘑"
		local label = ""

		local notify_num = wechat_notify:match('"StatusLabel"=%{ "label"="?(.-)"? %}')

		wechat:set({
			icon = {
				string = icon,
				color = colors.white,
			},
			label = { string = notify_num .. label },
		})
	end)
end)

wechat:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'WeChat'")
end)

sbar.add("bracket", "widgets.wechat.bracket", { wechat.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.wechat.padding", {
	position = "right",
	width = settings.group_paddings,
})
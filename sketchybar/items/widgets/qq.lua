local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local qq = sbar.add("item", "widgets.qq", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
	},
	label = { font = { family = settings.font.numbers } },
	update_freq = 8,
	drawing = true,
})

qq:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("lsappinfo -all list | grep qq", function(qq_notify)
		local icon = "󰘅"
		local label = ""

		local notify_num = qq_notify:match('"StatusLabel"=%{ "label"="?(.-)"? %}')

		if notify_num == nil or notify_num == "" then
			-- notify_num = "-"
			qq:set({
				icon = {
					string = icon,
					color = colors.white,
				},
				label = { string = notify_num .. label, drawing = false },
			})
		else
			qq:set({
				icon = {
					string = icon,
					color = colors.white,
				},
				label = { string = notify_num .. label },
			})
		end
	end)
end)

qq:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'QQ'")
end)

sbar.add("bracket", "widgets.qq.bracket", { qq.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.qq.padding", {
	position = "right",
	width = settings.group_paddings,
})

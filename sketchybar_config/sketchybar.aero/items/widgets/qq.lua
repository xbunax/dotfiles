local constants = require("constants")
local settings = require("config.settings")

local qq = sbar.add("item", "widgets.qq", {
	position = "right",
	icon = {
		font = {
			style = settings.fonts.styles.regular,
			size = 19,
		},
	},
	label = { font = { family = settings.fonts.numbers } },
	update_freq = 5,
})

qq:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("lsappinfo -all list | grep qq", function(qq_notify)
		local icon = "󰘅"
		local label = ""

		local notify_num = qq_notify:match('"StatusLabel"=%{ "label"="?(.-)"? %}')

		if notify_num == nil or notify_num == "" then
			qq:set({
				icon = {
					string = icon,
					color = settings.colors.white,
				},
				label = { drawing = false },
			})
		else
			qq:set({
				icon = {
					string = icon,
					color = settings.colors.white,
				},
				label = { string = notify_num .. label, drawing = true },
			})
		end
	end)
end)

qq:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'qq'")
end)

sbar.add("bracket", "widgets.qq.bracket", { qq.name }, {
	background = { color = settings.colors.bg1 },
})

sbar.add("item", "widgets.qq.padding", {
	position = "right",
	width = 5,
})

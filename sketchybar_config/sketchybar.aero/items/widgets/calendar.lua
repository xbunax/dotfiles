local settings = require("config.settings")
-- local colors = require("colors")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = 1 })

local cal = sbar.add("item", {
	icon = {
		color = settings.colors.white,
		padding_left = 8,
		font = {
			style = settings.fonts.styles.bold,
			size = 12.0,
		},
	},
	label = {
		color = settings.colors.white,
		padding_right = 10,
		width = 80,
		align = "right",
		font = { family = settings.fonts.numbers },
	},
	position = "right",
	update_freq = 1,
	padding_left = 1,
	padding_right = 1,
	background = {
		color = settings.colors.bg2,
		border_color = settings.colors.black,
		border_width = 1,
	},
})

-- Double border for calendar using a single item bracket
sbar.add("bracket", { cal.name }, {
	background = {
		color = settings.colors.transparent,
		height = 30,
		border_color = settings.colors.grey,
	},
})

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
	cal:set({ icon = os.date("%a. %d %b "), label = os.date("%H:%M:%S") })
end)

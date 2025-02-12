local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	topmost = "window",
	height = 35,
	notch_display_height = 33,
	-- margin = 15,
	-- corner_radius = 30,
	-- border_width = 1,
	-- border_color = 0xff89b4fa,
	color = colors.bar.bg,
	blur_radius = 20,
	padding_right = 5,
	padding_left = 5,
})

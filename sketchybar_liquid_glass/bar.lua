local colors = require("colors")

-- Liquid Glass Bar: 极透明底色 + 高模糊半径 + 白色玻璃边缘高光
sbar.bar({
	-- topmost = "off",
	height = 35,
	-- notch_offset = 10,
	-- y_offset = -10,
	notch_display_height = 33,
	-- margin = 15,
	-- corner_radius = 30,
	border_width = 0,
	border_color = colors.bar.border,
	color = colors.bar.bg,
	blur_radius = 0,
	padding_right = 5,
	padding_left = 5,
})

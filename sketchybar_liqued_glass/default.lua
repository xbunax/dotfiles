local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
	updates = "when_shown",
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 14.0,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
		background = { image = { corner_radius = 9 } },
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = 13.0,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	background = {
		-- 单个 item 默认透明，玻璃效果由外层 bracket 胶囊提供
		-- 避免 padding 间隔 item 也出现玻璃碎片
		height = 26,
		corner_radius = 9,
		border_width = 0,
		image = { corner_radius = 9 },
	},
	popup = {
		background = {
			border_width = 1,
			corner_radius = 14,      -- 更圆润，贴近 iOS 26 弹窗风格
			border_color = colors.popup.border,
			color = colors.popup.bg, -- 33% 黑色 + blur_radius 共同呈现液态玻璃
			shadow = { drawing = true },
		},
		blur_radius = 80,            -- 弹窗比 Bar 本身模糊度更高，更强的磨砂感
	},
	blur_radius = 70,
	padding_left = 4,
	padding_right = 4,
	scroll_texts = true,
})

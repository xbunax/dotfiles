local settings = require("config.settings")

sbar.default({
	updates = "when_shown",
	icon = {
		font = {
			family = settings.fonts.text,
			style = settings.fonts.styles.regular,
			size = settings.dimens.text.icon,
		},
		color = settings.colors.white,
		padding_left = settings.dimens.padding.icon,
		padding_right = settings.dimens.padding.icon,
	},
	label = {
		font = {
			family = settings.fonts.text,
			style = settings.fonts.styles.regular,
			size = settings.dimens.text.label,
		},
		color = settings.colors.white,
		padding_left = settings.dimens.padding.label,
		padding_right = settings.dimens.padding.label,
	},
	background = {
		height = 28,
		corner_radius = 9,
		border_width = 2,
		border_color = settings.colors.bg2,
		image = {
			corner_radius = 9,
			border_color = settings.colors.grey,
			border_width = 1,
		},
	},
	popup = {
		background = {
			border_width = 2,
			corner_radius = 9,
			border_color = settings.colors.popup.border,
			color = settings.colors.popup.bg,
			shadow = { drawing = true },
		},
		blur_radius = 20,
	},

	padding_left = 2,
	padding_right = 2,
	scroll_texts = true,
	-- slider = {
	-- 	highlight_color = settings.colors.orange,
	-- 	background = {
	-- 		height = settings.dimens.graphics.slider.height,
	-- 		corner_radius = settings.dimens.graphics.background.corner_radius,
	-- 		color = settings.colors.slider.bg,
	-- 		border_color = settings.colors.slider.border,
	-- 		border_width = 1,
	-- 	},
	-- 	knob = {
	-- 		font = {
	-- 			family = settings.fonts.text,
	-- 			style = settings.fonts.styles.regular,
	-- 			size = 32,
	-- 		},
	-- 		string = settings.icons.text.slider.knob,
	-- 		drawing = false,
	-- 	},
	-- },
})

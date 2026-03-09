-- iOS 26 Liquid Glass 液态玻璃配色方案
-- 设计原则：高透明度 + 高模糊半径 + 白色闪光边框 = 液态玻璃质感
return {
	-- iOS 26 系统色板（更鲜艳）
	black = 0xff1c1c1e,
	white = 0xffffffff,
	red = 0xffff453a,
	green = 0xff30d158,
	blue = 0xff0a84ff,
	yellow = 0xffffd60a,
	orange = 0xffff9f0a,
	magenta = 0xffbf5af2,
	grey = 0xffaeaeb2,
	transparent = 0x00000000,

	-- AeroSpace 工作区颜色（未聚焦=暗灰，聚焦=亮灰，统一灰阶语言）
	aerospace_label_color = 0xff8e8e93,         -- 未聚焦：iOS 系统灰
	aerospace_border_color = 0x30ffffff,         -- 聚焦边框：白色高光
	aerospace_label_highlight_color = 0xffe8e8ed, -- 聚焦标签：亮灰
	aerospace_icon_highlight_color = 0xffe8e8ed,  -- 聚焦图标：亮灰
	front_app_color = 0xffe8e8ed,

	-- 液态玻璃 Bar 背景（极低不透明度 + 高模糊 = 磨砂玻璃）
	bar = {
		bg = 0x00000000,   -- 13% 白色，极透明玻璃底色
		border = 0x00000000, -- 27% 白色，模拟玻璃边缘高光
	},
	-- 弹窗：液态玻璃（高透明 + 高模糊 = 真正穿透感）
	popup = {
		bg = 0x55000000,   -- 33% 黑色：半透明，配合 blur_radius 才是玻璃感
		border = 0x55ffffff, -- 33% 白色：玻璃边缘高光（比 Bar 边框略亮）
	},
	-- 控件分组背景（玻璃胶囊）
	bg1 = 0x20ffffff,  -- 12% 白色，玻璃 item 底色
	bg2 = 0x38ffffff,  -- 22% 白色，稍显眼的玻璃层
	bg3 = 0x1affffff,  -- 10% 白色，最外层极轻薄玻璃
	transparency = 0.85,
	blur_radius = 70,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}

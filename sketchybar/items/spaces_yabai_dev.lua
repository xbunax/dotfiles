local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local workspaces = {}

sbar.add("item", {
	width = 5,
})

for i = 1, 10, 1 do
	local workspace = sbar.add("space", "space." .. i, {
		space = i,
		icon = {
			font = { family = settings.font.numbers },
			string = i,
			padding_left = 10,
			padding_right = 5,
			color = colors.white,
			highlight_color = colors.aerospace_icon_highlight_color,
		},
		label = {
			padding_right = 10,
			color = colors.aerospace_label_color,
			highlight_color = colors.aerospace_label_highlight_color,
			font = "sketchybar-app-font:Regular:16.0",
			y_offset = -1,
		},
		padding_right = 1,
		padding_left = 1,
		background = {
			color = colors.transparent,
			-- color = colors.,
			border_width = 0,
			height = 28,
			border_color = colors.aerospace_border_color,
		},
		popup = { background = { color = colors.bg3, border_width = 5, border_color = colors.black } },
	})

	workspaces[i] = workspace

	-- Single item bracket for space items to achieve double border on highlight
	-- local space_bracket = sbar.add("bracket", { workspace.name }, {
	-- 	background = {
	-- 		color = colors.transparent,
	-- 		border_color = colors.bg2,
	-- 		height = 28,
	-- 		border_width = 2,
	-- 	},
	-- })

	-- Padding space
	sbar.add("space", "space.padding." .. i, {
		space = i,
		script = "",
		width = 0,
	})

	local space_popup = sbar.add("item", {
		position = "popup." .. workspace.name,
		padding_left = 0,
		padding_right = 0,
		background = {
			drawing = true,
			image = {
				corner_radius = 9,
				scale = 0.2,
			},
		},
	})

	workspace:subscribe("space_change", function(env)
		local selected = env.SELECTED == "true"
		local color = selected and colors.grey or colors.bg2
		workspace:set({
			icon = { highlight = selected },
			label = { highlight = selected },
			background = {
				border_width = selected and 1 or 0,
			},
			blur_radius = 20,
		})
		-- space_bracket:set({
		-- 	background = { border_color = selected and colors.grey or colors.bg2 },
		-- })
	end)

	workspace:subscribe("mouse.clicked", function(env)
		if env.BUTTON == "other" then
			space_popup:set({ background = { image = "space." .. env.SID } })
			workspace:set({ popup = { drawing = "toggle" } })
		else
			local op = (env.BUTTON == "right") and "--destroy" or "--focus"
			sbar.exec("yabai -m space " .. op .. " " .. env.SID)
		end
	end)

	workspace:subscribe("mouse.exited", function(_)
		workspace:set({ popup = { drawing = false } })
	end)
end

local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

-- local spaces_indicator = sbar.add("item", {
-- 	padding_left = -3,
-- 	padding_right = 0,
-- 	icon = {
-- 		padding_left = 8,
-- 		padding_right = 9,
-- 		color = colors.grey,
-- 		string = icons.switch.on,
-- 	},
-- 	label = {
-- 		width = 0,
-- 		padding_left = 0,
-- 		padding_right = 8,
-- 		string = "Spaces",
-- 		color = colors.bg1,
-- 	},
-- 	background = {
-- 		color = colors.with_alpha(colors.grey, 0.0),
-- 		border_color = colors.with_alpha(colors.bg1, 0.0),
-- 	},
-- })

space_window_observer:subscribe("space_windows_change", function(env)
	local icon_line = ""
	local no_app = true
	for app, count in pairs(env.INFO.apps) do
		no_app = false
		local lookup = app_icons[app]
		local icon = ((lookup == nil) and app_icons["Default"] or lookup)
		icon_line = icon_line .. icon
	end

	if no_app then
		icon_line = " —"
	end
	sbar.animate("tanh", 10, function()
		workspaces[env.INFO.space]:set({ label = icon_line })
	end)
end)

return workspaces

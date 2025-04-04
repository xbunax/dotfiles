local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local workspaces = {}

for i = 1, 10, 1 do
	local workspace = sbar.add("space", "space." .. i, {
		space = i,
		icon = {
			color = colors.white,
			highlight_color = colors.red,
			drawing = false,
		},
		label = {
			color = colors.grey,
			highlight_color = colors.white,
			drawing = false,
		},
		background = {
			-- color = colors.with_alpha(colors.bg1, colors.transparency),
			color = colors.bg3,
			border_width = 0,
			height = 28,
			border_color = colors.bg3,
			corner_radius = 9,
			drawing = false,
		},
		padding_left = 6,
		padding_right = 0,
		popup = { background = { border_width = 5, border_color = colors.black } },
	})

	workspaces[i] = workspace
	-- Single item bracket for space items to achieve double border on highlight
	local space_bracket = sbar.add("bracket", { workspace.name }, {
		background = {
			color = colors.transparent,
			border_color = colors.bg2,
			height = 28,
			border_width = 2,
		},
	})

	-- Padding space
	sbar.add("space", "space.padding." .. i, {
		space = i,
		script = "",
		width = settings.group_paddings,
	})

	local space_popup = sbar.add("item", {
		position = "popup." .. workspace.name,
		padding_left = 5,
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
			background = { border_color = selected and colors.black or colors.bg2 },
		})
		space_bracket:set({
			background = { border_color = selected and colors.grey or colors.bg2 },
		})
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

local spaces_indicator = sbar.add("item", {
	icon = {
		color = colors.white,
		-- color = colors.black,
		-- highlight_color = colors.red,
		highlight_color = colors.aerospace_icon_highlight_color,
		drawing = false,
		font = { family = settings.font.numbers },
		string = icons.switch.on,
		padding_left = 10,
		padding_right = 5,
	},
	label = {
		padding_right = 10,
		-- color = colors.grey,
		color = colors.aerospace_label_color,
		highlight_color = colors.aerospace_label_highlight_color,
		string = "Spaces",
		font = "sketchybar-app-font:Regular:16.0",
		y_offset = -1,
	},
	padding_right = 2,
	padding_left = 2,
	background = {
		-- color = colors.bg3,
		border_width = 0,
		height = 28,
		border_color = colors.aerospace_border_color,
	},
})

space_window_observer:subscribe("space_windows_change", function(env)
	local icon_line = ""
	local no_app = true
	for app, count in pairs(env.INFO.apps) do
		no_app = false
		local lookup = app_icons[app]
		local icon = ((lookup == nil) and app_icons["default"] or lookup)
		icon_line = icon_line .. " " .. icon
	end

	if no_app then
		icon_line = " — "
		-- icon_line = ""
	end
	sbar.animate("tanh", 10, function()
		workspaces[env.INFO.space]:set({ label = icon_line })
	end)
end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

spaces_indicator:subscribe("mouse.entered", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 1.0 },
				border_color = { alpha = 1.0 },
			},
			icon = { color = colors.bg1 },
			label = { width = "dynamic" },
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = { alpha = 0.0 },
				border_color = { alpha = 0.0 },
			},
			icon = { color = colors.grey },
			label = { width = 0 },
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
	sbar.trigger("swap_menus_and_spaces")
end)

return workspaces

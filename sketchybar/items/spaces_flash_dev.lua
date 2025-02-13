-- items/aerospace.lua
local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local app_icons = require("helpers.app_icons")

sbar.add("event", "flashspace_workspace_change")
local max_workspaces = 10
local map_monitor = { ["24B1W1"] = 1, ["Built-in Retina Display"] = 2 }

-- Add padding to the left
sbar.add("item", {
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
})

local workspaces = {}

local function updateWindows(workspace_index)
	local get_windows = string.format(
		"jq -c '.profiles[].workspaces[] | select(.name == \"%s\") | {apps: [.apps[].name]}' ~/.config/flashspace/profiles.json",
		workspace_index
	)
	sbar.exec(get_windows, function(open_windows)
		local apps = open_windows.apps or {}

		local icon_line = ""
		local no_app = (#apps == 0)

		-- 遍历应用名列表
		for _, app_name in ipairs(apps) do
			local lookup = app_icons[app_name]
			local icon = lookup or app_icons["Default"]
			icon_line = icon_line .. " " .. icon
		end

		sbar.animate("sin", 15, function()
			-- for i, visible_workspace in ipairs(visible_workspaces) do
			-- 	if no_app and workspace_index == tonumber(visible_workspace["workspace"]) then
			-- 		local monitor_id = visible_workspace["monitor-appkit-nsscreen-screens-id"]
			-- 		icon_line = " —"
			-- 		workspaces[workspace_index]:set({
			-- 			icon = { drawing = true },
			-- 			label = {
			-- 				string = icon_line,
			-- 				drawing = true,
			-- 				-- padding_right = 20,
			-- 				font = "sketchybar-app-font:Regular:16.0",
			-- 				y_offset = -1,
			-- 			},
			-- 			background = { drawing = true },
			-- 			padding_right = 1,
			-- 			padding_left = 1,
			-- 			display = monitor_id,
			-- 		})
			-- 		return
			-- 	end
			-- end

			if no_app and workspace_index ~= tonumber(focused_workspace) then
				workspaces[workspace_index]:set({
					icon = { drawing = false },
					label = { drawing = false },
					background = { drawing = false },
					padding_right = 0,
					padding_left = 0,
				})
				return
			end
			if no_app and workspace_index == tonumber(focused_workspace) then
				icon_line = " —"
				workspaces[workspace_index]:set({
					icon = { drawing = true },
					label = {
						string = icon_line,
						drawing = true,
						-- padding_right = 20,
						font = "sketchybar-app-font:Regular:16.0",
						y_offset = -1,
					},
					background = { drawing = true },
					padding_right = 1,
					padding_left = 1,
				})
			end

			workspaces[workspace_index]:set({
				icon = { drawing = true },
				label = { drawing = true, string = icon_line },
				background = { drawing = true },
				padding_right = 1,
				padding_left = 1,
			})
		end)
	end)
end

--
local function updateWorkspaceMonitor(workspace_index)
	local query_workspaces = string.format(
		"jq -r --arg name \"%s\" '.profiles[].workspaces[] | select(.name == $name) | .display' ~/.config/flashspace/profiles.json",
		workspace_index
	)
	sbar.exec(query_workspaces, function(workspaces_and_monitors)
		workspaces_and_monitors = string.gsub(workspaces_and_monitors, "\n", "")
		local index = map_monitor[workspaces_and_monitors]
		workspaces[workspace_index]:set({
			display = tonumber(index),
		})
	end)
end

for workspace_index = 1, max_workspaces do
	print(workspace_index)
	local workspace = sbar.add("item", {
		icon = {
			color = colors.white,
			highlight_color = colors.aerospace_icon_highlight_color,
			drawing = false,
			font = { family = settings.font.numbers },
			string = workspace_index,
			padding_left = 10,
			padding_right = 5,
		},
		label = {
			padding_right = 10,
			-- color = colors.grey,
			color = colors.aerospace_label_color,
			highlight_color = colors.aerospace_label_highlight_color,
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
		-- click_script = "aerospace workspace " .. workspace_index,
	})

	workspaces[workspace_index] = workspace
	updateWindows(workspace_index)
	updateWorkspaceMonitor(workspace_index)

	workspace:subscribe("flashspace_workspace_change", function(env)
		focused_workspace = tonumber(env.FOCUSED_WORKSPACE)
		local is_focused = focused_workspace == workspace_index
		updateWindows(tonumber(env.FOCUSED_WORKSPACE))
		sbar.animate("circ", 15, function()
			workspace:set({
				icon = { highlight = is_focused },
				label = { highlight = is_focused },
				background = {
					border_width = is_focused and 1 or 0,
				},
				blur_radius = 20,
			})
		end)
		-- sbar.animate("sin", 15, function()
		-- 	workspaces[tonumber(env.FOCUSED_WORKSPACE)]:set({
		-- 		icon = { highlight = true },
		-- 		label = { highlight = true },
		-- 		background = { border_width = 1 },
		-- 	})
		-- end)
		updateWindows(workspace_index)
	end)
end

return workspaces

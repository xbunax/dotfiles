-- items/spaces_rift_dev.lua
local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local app_icons = require("helpers.app_icons")

sbar.add("event", "SPACE_TRIGGER")
sbar.add("event", "rift_workspace_change")
local max_workspaces = 10
local workspace_monitor = {}

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
local empty_workspaces = {}
local focus_handlers = {}

-- Rift indexes are zero-based; the bar keeps the original labels 1..10.
-- Uses rift-cli JSON queries. Polling keeps this file self-contained: no
-- subscriptions, helper scripts or changes to the Rift configuration required.
local rift_cli = os.getenv("RIFT_CLI") or "rift-cli"
local function quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end
local cli = quote(rift_cli)
local snapshot = { entries = {}, visible = {}, windows = {}, empty = {}, focused = nil }
local wm_adapter = {}

function wm_adapter.query_workspaces(callback)
	local entries = {}
	for index = 1, max_workspaces do
		if snapshot.entries[index] then table.insert(entries, snapshot.entries[index]) end
	end
	callback(entries)
end
function wm_adapter.query_empty_workspaces_sync()
	return snapshot.empty
end
function wm_adapter.query_visible_workspaces(callback)
	callback(snapshot.visible)
end
function wm_adapter.query_focused_workspace(callback)
	callback(snapshot.focused)
end
function wm_adapter.query_windows(index, callback)
	callback(snapshot.windows[index] or {})
end
function wm_adapter.focus_workspace(index)
	local entry = snapshot.entries[index]
	if not entry then return end
	local command = cli .. " execute workspace switch " .. (index - 1)
	if entry.display_uuid then
		command = cli .. " execute display focus --uuid " .. quote(entry.display_uuid)
			.. " && " .. command
	end
	sbar.exec(command)
end

local refreshing = false
local function refresh_snapshot(callback)
	if refreshing then return end
	refreshing = true
	-- Rift screen_id is a CoreGraphics ID, not SketchyBar's arrangement ID.
	sbar.exec("sketchybar --query displays", function(bar_displays, bar_code)
		if bar_code ~= 0 or type(bar_displays) ~= "table" then
			refreshing = false
			return
		end
		local display_ids = {}
		for _, display in ipairs(bar_displays) do
			display_ids[display.UUID] = display["arrangement-id"]
		end
	sbar.exec(cli .. " query displays", function(displays, code)
		if code ~= 0 or type(displays) ~= "table" or #displays == 0 then
			refreshing = false
			return
		end
		local next_snapshot = { entries = {}, visible = {}, windows = {}, empty = {}, focused = nil }
		local pending = #displays
		local failed = false
		for _, display in ipairs(displays) do
			sbar.exec(cli .. " query workspaces --display " .. quote(display.uuid), function(rows, status)
				if status ~= 0 or type(rows) ~= "table" then
					failed = true
				else
					for _, row in ipairs(rows) do
						local index = tonumber(row.index)
						if index and index >= 0 and index < max_workspaces then
							index = index + 1
							local previous = next_snapshot.entries[index]
							-- Older Rift versions may expose per-display workspace indexes.
							-- Prefer the focused/visible instance when an index repeats.
							local focused = row.is_focused == true
								or (row.is_active and display.is_active_context == true)
							if not previous or focused or (row.is_active and not previous.active) then
								next_snapshot.entries[index] = {
									workspace = index,
									["monitor-appkit-nsscreen-screens-id"] = display_ids[display.uuid] or "active",
									display_uuid = display.uuid,
									active = row.is_active,
									focused = focused,
								}
								local windows = {}
								for _, window in ipairs(row.windows or {}) do
									windows[#windows + 1] = { ["app-name"] = window.app_name or "Default" }
								end
								next_snapshot.windows[index] = windows
							end
						end
					end
				end
				pending = pending - 1
				if pending ~= 0 then return end
				refreshing = false
				if failed then return end
				for index = 1, max_workspaces do
					local entry = next_snapshot.entries[index]
					if entry then
						if entry.active then table.insert(next_snapshot.visible, entry) end
						if entry.focused then next_snapshot.focused = index end
					end
					if entry and #(next_snapshot.windows[index] or {}) == 0 then
						table.insert(next_snapshot.empty, index)
					end
				end
				snapshot = next_snapshot
				callback()
			end)
		end
	end)
	end)
end

local function updateWindows(workspace_index)
	wm_adapter.query_windows(workspace_index, function(open_windows)
		wm_adapter.query_focused_workspace(function(focused_workspaces)
			wm_adapter.query_visible_workspaces(function(visible_workspaces)
				local icon_line = ""
				local no_app = true
				for _, open_window in ipairs(open_windows) do
					no_app = false
					local app = open_window["app-name"]
					local lookup = app_icons[app]
					local icon = ((lookup == nil) and app_icons["Default"] or lookup)
					icon_line = icon_line .. " " .. icon
				end

				sbar.animate("sin", 15, function()
					for _, visible_workspace in ipairs(visible_workspaces) do
						if no_app and workspace_index == tonumber(visible_workspace["workspace"]) then
							local monitor_id = visible_workspace["monitor-appkit-nsscreen-screens-id"]
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
								display = monitor_id,
							})
							return
						end
					end

					if no_app and workspace_index ~= tonumber(focused_workspaces) then
						workspaces[workspace_index]:set({
							icon = { drawing = false },
							label = { drawing = false },
							background = { drawing = false },
							padding_right = 0,
							padding_left = 0,
						})
						return
					end
					if no_app and workspace_index == tonumber(focused_workspaces) then
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
		end)
	end)
end

local function updateWorkspaceMonitor(workspace_index)
	wm_adapter.query_workspaces(function(workspaces_and_monitors)
		for _, entry in ipairs(workspaces_and_monitors) do
			local space_index = tonumber(entry.workspace)
			local monitor_id = entry["monitor-appkit-nsscreen-screens-id"]
			workspace_monitor[space_index] = monitor_id
		end
		workspaces[workspace_index]:set({
			display = workspace_monitor[workspace_index] or "active",
		})
	end)
end

local function updateWorkspaceHover(workspace_index, trigger)
	if trigger == true then
		sbar.animate("sin", 15, function()
			local icon_line = " —"
			workspaces[workspace_index]:set({
				icon = { drawing = true },
				label = {
					string = icon_line,
					drawing = true,
					font = "sketchybar-app-font:Regular:16.0",
					y_offset = -1,
				},
				background = { drawing = true },
				padding_right = 1,
				padding_left = 1,
			})
		end)
	else
		sbar.animate("sin", 15, function()
			workspaces[workspace_index]:set({
				icon = { drawing = false },
				label = { drawing = false },
				background = { drawing = false },
				padding_right = 0,
				padding_left = 0,
			})
			return
		end)
	end
end

for workspace_index = 1, max_workspaces do
	local workspace = sbar.add("item", {
		icon = {
			color = colors.aerospace_label_color, -- 未聚焦：暗灰
			highlight_color = colors.aerospace_icon_highlight_color, -- 聚焦：亮灰
			drawing = false,
			font = { family = settings.font.numbers },
			string = workspace_index,
			padding_left = 10,
			padding_right = 5,
		},
		label = {
			padding_right = 10,
			color = colors.aerospace_label_color, -- 未聚焦：暗灰
			highlight_color = colors.aerospace_label_highlight_color, -- 聚焦：亮灰
			font = "sketchybar-app-font:Regular:16.0",
			y_offset = -1,
		},
		padding_right = 2,
		padding_left = 2,
		background = {
			color = colors.transparent,
			border_width = 0,
			height = 28,
			border_color = colors.aerospace_border_color,
		},
	})

	workspaces[workspace_index] = workspace

	workspace:subscribe("mouse.clicked", function()
		wm_adapter.focus_workspace(workspace_index)
	end)

	local function updateFocus(env)
		local focused_workspace = tonumber(env.FOCUSED_WORKSPACE)
		local is_focused = focused_workspace == workspace_index

		sbar.animate("circ", 15, function()
			workspace:set({
				icon = { highlight = is_focused },
				label = { highlight = is_focused },
				background = {
					-- 聚焦时：显示极微透明白色玻璃底 + 高光白边；非聚焦：完全透明
					color = is_focused and 0x20ffffff or colors.transparent,
					border_width = is_focused and 1 or 0,
					border_color = colors.aerospace_border_color,
				},
				blur_radius = 70,
			})
		end)
	end
	focus_handlers[workspace_index] = updateFocus
	workspace:subscribe("rift_workspace_change", updateFocus)

	-- workspace:subscribe("mouse.entered", function()
	-- 	sbar.animate("tanh", 30, function()
	-- 		workspace:set({
	-- 			background = {
	-- 				color = colors.with_alpha(colors.white, 0.15),
	-- 				border_color = colors.with_alpha(colors.white, 0.35),
	-- 			},
	-- 		})
	-- 	end)
	-- end)

	-- workspace:subscribe({ "mouse.exited", "mouse.exited.global" }, function()
	-- 	sbar.animate("tanh", 30, function()
	-- 		workspace:set({
	-- 			background = {
	-- 				color = colors.transparent,
	-- 				height = 28,
	-- 				border_color = colors.aerospace_border_color,
	-- 			},
	-- 		})
	-- 	end)
	-- end)

	workspace:subscribe("SPACE_TRIGGER", function(env)
		local empty_workspaces_list = wm_adapter.query_empty_workspaces_sync()
		-- local trigger_detail = env.detail == "true"
		if env.detail == "true" then
			for _, index_enter in ipairs(empty_workspaces_list) do
				updateWorkspaceHover(index_enter, true)
			end
		elseif env.detail == "false" then
			for _, index_exited in ipairs(empty_workspaces_list) do
				updateWindows(index_exited)
				-- print(index_exited)
				-- updateWorkspaceHover(index_exited, false)
			end
		end
	end)
	--
	-- workspace:subscribe("mouse.exited", function()
	-- 	updateWindows(workspace_index)
	-- end)

	workspace:subscribe("display_change", function()
		updateWorkspaceMonitor(workspace_index)
		updateWindows(workspace_index)
	end)


end

-- One hidden timer refreshes all items from one coherent snapshot.
local observer = sbar.add("item", "rift.spaces.observer", {
	drawing = false,
	updates = "on",
	update_freq = 1,
})
local function refresh()
	refresh_snapshot(function()
		for index = 1, max_workspaces do
			updateWorkspaceMonitor(index)
			updateWindows(index)
			focus_handlers[index]({ FOCUSED_WORKSPACE = snapshot.focused })
		end
	end)
end
observer:subscribe({ "routine", "forced", "display_change", "system_woke", "front_app_switched" }, refresh)
refresh()

return workspaces

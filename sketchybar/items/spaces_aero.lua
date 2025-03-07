local colors = require("colors")
local icons = require("icons").text
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local constants = require("default")
local aerospace = sbar.aerospace
local cjson = require("cjson")
local json = cjson.new()

local spaces = {}
local icon_cache = {}
local isShowingMenu = false
local swapWatcher = sbar.add("item", {
	drawing = false,
	updates = true,
})

local ANIM_DURATION_SHORT = 10
local ANIM_DURATION_MEDIUM = 20
local ANIM_DURATION_LONG = 30

sbar.exec("killall sb_events >/dev/null; $CONFIG_DIR/bridge/events/bin/sb_events")

local function animateSpaceIcon(space, color, iconStr, labelStr, shouldDraw, animate, d)
	if not d then
		space.item:set({
			label = { drawing = true, string = labelStr },
		})
	end
	if shouldDraw and d then
		space.item:set({
			icon = {
				drawing = true,
				color = colors.white,
				string = iconStr,
			},
			label = { drawing = true, string = labelStr },
			drawing = shouldDraw,
			background = { border_width = 1, border_color = colors.aerospace_border_color },
		})
		if animate then
			sbar.animate("tanh", ANIM_DURATION_SHORT, function()
				space.item:set({ icon = { color = colors.aerospace_icon_highlight_color } })
			end)
		end
	elseif not shouldDraw then
		space.item:set({ drawing = false })
		space.padding:set({ drawing = false })
	end
end

local function getIconForApp(appName)
	if icon_cache[appName] then
		return icon_cache[appName]
	end
	local icon = app_icons[appName] or app_icons["Default"] or "?"
	icon_cache[appName] = icon
	return icon
end

local function updateAllIcons(focusedWorkspace, animate, d, filter)
	local allWindows = aerospace:list_all_windows()
	local windowsByWorkspace = {}
	for _, window in ipairs(allWindows) do
		local ws = window.workspace
		windowsByWorkspace[ws] = windowsByWorkspace[ws] or {}
		windowsByWorkspace[ws][#windowsByWorkspace[ws] + 1] = window
	end

	for spaceId, entry in pairs(spaces) do
		if filter and filter[entry.workspace] then
			goto continue
		end
		local workspaceName = entry.workspace
		local isSelected = (workspaceName == focusedWorkspace)
		local apps = windowsByWorkspace[workspaceName] or {}
		local noApps = (#apps == 0)

		local iconLine
		if noApps then
			iconLine = "—"
		else
			local iconsList = {}
			for _, window in ipairs(apps) do
				iconsList[#iconsList + 1] = getIconForApp(window["app-name"])
			end
			iconLine = table.concat(iconsList)
		end

		local shouldDraw = (not noApps or isSelected) and not isShowingMenu

		local current = entry.item:query()
		if current.label and current.label.value == iconLine and current.drawing == shouldDraw then
			goto continue
		end

		local spaceColor, spaceIcon
		if noApps then
			if isSelected then
				spaceColor = colors.aerospace_label_highlight_color
				spaceIcon = focusedWorkspace
			else
				spaceColor = colors.white
				spaceIcon = icons.space_icon.not_active
			end
		else
			spaceColor = colors.red
			if isSelected then
				spaceIcon = icons.space_icon.active
			else
				spaceIcon = icons.space_icon.not_active_has_apps
			end
		end

		local function updateSpace()
			entry.item:set({
				icon = { color = spaceColor, string = spaceIcon },
				label = iconLine,
				drawing = shouldDraw,
				background = { border_width = isSelected and 1 or 0 },
			})
			entry.padding:set({ drawing = shouldDraw })
		end

		if isSelected then
			animateSpaceIcon(entry, spaceColor, spaceIcon, iconLine, shouldDraw, animate, d)
		else
			if animate then
				sbar.animate("tanh", ANIM_DURATION_SHORT, updateSpace)
			else
				updateSpace()
			end
		end

		::continue::
	end
end

local function addWorkspace(workspaceName, monitorId)
	local spaceId = "workspace_" .. workspaceName .. "_" .. monitorId
	if not spaces[spaceId] then
		local space = sbar.add("item", spaceId, {
			position = "left",
			icon = {
				font = { family = settings.fonts.numbers },
				string = workspaceName,
				padding_left = 8,
				padding_right = 5,
				color = colors.white,
				highlight_color = colors.aerospace_icon_highlight_color,
				drawing = true,
			},
			label = {
				padding_right = 10,
				-- padding_left = 10,
				color = colors.aerospace_label_color,
				highlight_color = colors.aerospace_label_highlight_color,
				font = "sketchybar-app-font:Regular:14.0",
			},
			padding_right = 1,
			padding_left = 1,
			background = {
				color = colors.transparent,
				border_color = colors.aerospace_border_color,
				height = 28,
				-- corner_radius = 16,
				border_width = 0,
			},
			display = monitorId,
			drawing = false,
		})

		local padding = sbar.add("item", spaceId .. "padding", {
			position = "left",
			script = "",
			width = 3, --settings.group_paddings,
		})

		spaces[spaceId] = {
			item = space,
			padding = padding,
			workspace = workspaceName,
		}

		space:subscribe("mouse.clicked", function()
			aerospace:workspace(workspaceName)
		end)

		space:subscribe("mouse.entered", function()
			local space_is_selected = (space:query().icon.value == icons.space_icon.active)
			if not space_is_selected then
				sbar.animate("tanh", ANIM_DURATION_MEDIUM, function()
					space:set({
						background = {
							color = colors.bg3,
							border_color = colors.with_alpha(colors.grey, 0.5),
							border_width = 1,
						},
					})
				end)
			end
		end)

		space:subscribe("mouse.exited.global", function()
			local space_is_selected = (space:query().icon.value == icons.space_icon.active)
			if not space_is_selected then
				sbar.animate("tanh", ANIM_DURATION_LONG, function()
					space:set({
						background = {
							color = colors.transparent,
							border_color = colors.transparent,
						},
					})
				end)
			end
		end)
	end
end

local function removeWorkspaceItem(spaceId)
	if spaces[spaceId] then
		sbar.remove(spaces[spaceId].item)
		sbar.remove(spaces[spaceId].padding)
		spaces[spaceId] = nil
	end
end

local function updateAll(animate, d)
	aerospace:list_current(function(focusedWorkspaceOutput)
		local focusedWorkspace = focusedWorkspaceOutput:match("[^\r\n]+") or ""
		aerospace:query_workspaces(function(workspaces_and_monitors)
			local updatedSpaces = {}

			for _, entry in ipairs(workspaces_and_monitors) do
				local workspaceName = entry.workspace
				local monitorId = math.floor(entry["monitor-appkit-nsscreen-screens-id"])
				local spaceId = "workspace_" .. workspaceName .. "_" .. monitorId

				addWorkspace(workspaceName, monitorId)
				updatedSpaces[spaceId] = true
			end

			for spaceId in pairs(spaces) do
				if not updatedSpaces[spaceId] then
					removeWorkspaceItem(spaceId)
				end
			end

			updateAllIcons(focusedWorkspace, animate, d)
		end)
	end)
end

updateAll(true, true)

local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

space_window_observer:subscribe("aerospace_workspace_changed", function(env)
	updateAllIcons(env.FOCUSED_WORKSPACE, true, true, { env.FOCUSED_WORKSPACE, env.PREV_WORKSPACE })
end)

space_window_observer:subscribe({ "app_change", "front_app_switched" }, function(env)
	if env["SENDER"] == "front_app_switched" and env["INFO"] then
		return
	end
	updateAll(false, false)
end)

space_window_observer:subscribe({ "system_woke", "reload_aerospace" }, function(env)
	sbar.aerospace:reconnect()
end)

local function switchToggle()
	isShowingMenu = not isShowingMenu

	sbar.trigger(constants.events.SWAP_MENU_AND_SPACES, { isShowingMenu = isShowingMenu })
end

swapWatcher:subscribe(constants.events.SWAP_MENU_AND_SPACES, function(env)
	isShowingMenu = env.isShowingMenu ~= "off"
	updateAll(false, true)
end)

swapWatcher:subscribe(constants.events.AEROSPACE_SWITCH, function(env)
	switchToggle()
end)

return spaces

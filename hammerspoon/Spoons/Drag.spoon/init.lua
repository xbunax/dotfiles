local Drag = {}
Drag.__index = Drag

-- Metadata
Drag.name = "Drag"
Drag.version = "0.1"
Drag.author = "Michael Mogenson"
Drag.homepage = "https://github.com/mogenson/drag.spoon"
Drag.license = "MIT - https://opensource.org/licenses/MIT"

-- helper time function

local function wait(seconds)
	local start = hs.timer.secondsSinceEpoch()
	while hs.timer.secondsSinceEpoch() - start < seconds do
	end
end

-- helper mouse functions

local function mouseMove(position)
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.mouseMoved, position):post()
end

local function mouseDown(position)
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, position):post()
end

local function mouseUp(position)
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, position):post()
end

local function mouseClick(position)
	mouseDown(position)
	mouseUp(position)
end

local function mouseDrag(start_position, end_position)
	mouseMove(start_position)
	mouseDown(start_position)
	hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDragged, end_position):post()
	mouseUp(end_position)
end

-- helper mission control functions

function getMissionControlGroup()
	local dock_app = hs.application.applicationsForBundleID("com.apple.dock")[1]
	local dock_element = hs.axuielement.applicationElement(dock_app)
	for _, element in ipairs(dock_element) do
		if element.AXIdentifier == "mc" then
			return element
		end
	end

	return nil, "mission control is not open"
end

function getDisplayGroups()
	local mc_group, err = getMissionControlGroup()
	if err then
		return nil, err
	end

	local display_groups = {}
	for _, element in ipairs(mc_group) do
		if element.AXIdentifier == "mc.display" then
			table.insert(display_groups, element)
		end
	end

	return display_groups
end

function getMissionControlWindows()
	local display_groups, err = getDisplayGroups()
	if err then
		return nil, err
	end

	local windows = {}
	for _, group in ipairs(display_groups) do
		for _, element in ipairs(group) do
			if element.AXIdentifier == "mc.windows" then
				for _, mc_window in ipairs(element) do
					table.insert(windows, mc_window)
				end
			end
		end
	end

	return windows
end

function getMissionControlSpaces()
	local display_groups, err = getDisplayGroups()
	if err or not display_groups then
		return nil, err
	end

	local spaces = {}
	for _, display_group in ipairs(display_groups) do
		for _, element in ipairs(display_group) do
			if element.AXIdentifier == "mc.spaces" then
				local mc_spaces = element
				for _, element in ipairs(mc_spaces) do
					if element.AXIdentifier == "mc.spaces.list" then
						local mc_spaces_list = element
						for _, mc_space in ipairs(mc_spaces_list) do
							table.insert(spaces, mc_space)
						end
					end
				end
			end
		end
	end

	return spaces
end

local function getSpaceIndex(space_id)
	local layout = hs.spaces.allSpaces()
	local index = 0
	for _, screen in ipairs(hs.screen.allScreens()) do
		local screen_uuid = screen:getUUID()
		for i, space in ipairs(layout[screen_uuid]) do
			if space == space_id then
				return index + i
			end
		end
		index = index + #layout[screen_uuid]
	end

	return nil
end

-- move focused window to new space

function Drag:focusedWindowToSpace(space_id)
	local log = hs.logger.new(self.name)

	local focused_window = hs.window.focusedWindow()
	if not focused_window then
		log.e("no focused window")
		return
	end

	local title = focused_window:title()
	if not title or #title == 0 then
		title = focused_window:application():title()
	end
	if not title or #title == 0 then
		log.e("no title for window")
		return
	end

	local space_index = getSpaceIndex(space_id)
	if not space_index then
		log.e("can't find space_id in spaces")
	end

	log.vf("moving window %s to space %d", title, space_index)

	-- open mission control and move mouse to expand spaces list
	hs.spaces.openMissionControl()
	mouseMove({ x = 10, y = 10 })

	-- get all windows in mission control
	local windows, err = getMissionControlWindows()
	if err or not windows then
		log.ef("couldn't get mission control windows: %s", err)
		return
	end

	-- find position of window with matching title
	local start_position
	repeat
		log.vf("looking for window with title: %s", title)
		for _, window in ipairs(windows) do
			if window.AXTitle:find(title, 1, true) then
				start_position = hs.geometry(window.AXFrame).center
			end
		end
		-- remove either the last word or the last character until we have a match
		local separater = title:find("%s+%S*$") or #title
		title = title:sub(1, separater - 1)
	until start_position or #title == 0
	if not start_position then
		log.e("couldn't find mission control window")
		return
	end

	-- get all spaces in mission control
	local spaces, err = getMissionControlSpaces()
	if err or not spaces then
		log.ef("couldn't get mission control spaces: %s", err)
		return
	end

	-- get space for space index
	local space = spaces[space_index]
	if not space then
		log.ef("no space for space index: %d", space_index)
		return
	end

	-- get position of space
	local end_position = hs.geometry(space.AXFrame).center
	log.vf("draging window from %s to %s", start_position, end_position)

	-- drag window to space then click on space to switch
	wait(hs.spaces.MCwaitTime)
	mouseDrag(start_position, end_position)
	wait(hs.spaces.MCwaitTime)
	mouseClick(end_position)
end

return Drag

--- IME Switcher Module
-- Handles input method switching with double-tap escape key functionality
-- @module ime-switcher

local obj = {}
obj.__index = obj
-- Initialize with Hammerspoon API
obj.hs = hs

-- Constants
local ESCAPE_KEY_CODE = 53
local DOUBLE_TAP_INTERVAL = 250 -- milliseconds
local ENGLISH_INPUT_SOURCE = "com.apple.keylayout.ABC"

-- Module state
local lastEscPress = 0
local escTapEvent = nil

--- Switches the input source to English ABC if it's not already active
local function switchToEnglishABC()
	local currentSource = obj.hs.keycodes.currentSourceID()

	if currentSource ~= ENGLISH_INPUT_SOURCE then
		obj.hs.keycodes.currentSourceID(ENGLISH_INPUT_SOURCE)
	end
end

--- Handles keyboard events, specifically looking for double-tap escape
-- @param tapEvent The keyboard event to handle
-- @return false to allow the event to propagate
local function handleKeyEvent(tapEvent)
	if not tapEvent then
		return false
	end

	local keyCode = tapEvent:getKeyCode()
	if keyCode == ESCAPE_KEY_CODE then
		local timeNow = obj.hs.timer.secondsSinceEpoch() * 1000

		if timeNow - lastEscPress < DOUBLE_TAP_INTERVAL then
			switchToEnglishABC()
		end

		lastEscPress = timeNow
	end

	return false
end

--- Initializes the IME switcher
-- Sets up event tap and cleanup handlers
function obj:init()
	if not self.hs then
		error("Hammerspoon API not available")
		return
	end

	-- Clean up any existing event tap
	if escTapEvent then
		escTapEvent:stop()
	end

	-- Create new event tap
	escTapEvent = self.hs.eventtap.new({ self.hs.eventtap.event.types.keyUp }, handleKeyEvent)

	if escTapEvent then
		escTapEvent:start()
	else
		error("Failed to create event tap")
		return
	end

	-- Ensure cleanup on shutdown
	self.hs.shutdownCallback = function()
		if escTapEvent then
			escTapEvent:stop()
			escTapEvent = nil
		end
	end
end

return obj

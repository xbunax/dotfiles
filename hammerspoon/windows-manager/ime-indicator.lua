-- **************************************************
-- IME Indicator
-- Credit to https://github.com/xiaojundebug/hammerspoon-config
-- **************************************************

local obj = {}
obj.__index = obj
obj.hs = hs

obj.canvases = {}
obj.lastSourceID = nil
obj.distributedNotification = nil
obj.indicatorSyncTimer = nil
obj.screenWatcher = nil

-- --------------------------------------------------
-- Configuration
obj.config = {
	HEIGHT = 5,
	ALPHA = 1,
	IME_COLORS = {
		["im.rime.inputmethod.Squirrel.Hans"] = {
			-- { hex = '#dc2626' },
			-- { hex = '#eab308' },
			{ hex = "#0ea5e9" },
		},
		["im.rime.inputmethod.Squirrel.Hant"] = { { hex = "#0ea5e9" } },
	},
}

-- Cache frequently used functions for better performance
local floor = math.floor
local allScreens = hs.screen.allScreens
local windowLevels = hs.canvas.windowLevels
local windowBehaviors = hs.canvas.windowBehaviors

-- Draw indicator
function obj:draw(colors)
	local screens = allScreens()

	for i, screen in ipairs(screens) do
		local frame = screen:fullFrame()
		local canvas = hs.canvas.new({
			x = floor(frame.x),
			y = floor(frame.y),
			w = floor(frame.w),
			h = self.config.HEIGHT,
		})

		canvas:level(windowLevels.overlay)
		canvas:behavior(windowBehaviors.canJoinAllSpaces)
		canvas:alpha(self.config.ALPHA)

		if #colors == 1 then
			canvas[1] = {
				type = "rectangle",
				action = "fill",
				fillColor = colors[1],
				frame = { x = 0, y = 0, w = frame.w, h = self.config.HEIGHT },
			}
		else
			-- Multi-color handling
			local rect = {
				type = "rectangle",
				action = "fill",
				fillGradient = "linear",
				fillGradientColors = colors,
				frame = { x = 0, y = 0, w = frame.w, h = HEIHGT },
			}
			canvas[1] = rect
		end

		canvas:show()
		self.canvases[i] = canvas
	end
end

-- Clear canvas content
function obj:clear()
	for _, canvas in ipairs(self.canvases) do
		canvas:delete()
	end
	self.canvases = {}
end

function obj:update(sourceID)
	self:clear()
	local currentSourceID = sourceID or self.hs.keycodes.currentSourceID()
	local colors = self.config.IME_COLORS[currentSourceID]

	if colors then
		self:draw(colors)
	end
end

function obj:handleInputSourceChanged()
	local currentSourceID = self.hs.keycodes.currentSourceID()

	if self.lastSourceID ~= currentSourceID then
		self:update(currentSourceID)
		self.lastSourceID = currentSourceID
	end
end

function obj:init()
	-- Input method change event listener
	-- Sometimes hs.keycodes.inputSourceChanged doesn't trigger, monitoring system events solves this
	-- Reference: https://github.com/Hammerspoon/hammerspoon/issues/1499
	self.distributedNotification = self.hs.distributednotifications.new(
		function()
			self:handleInputSourceChanged()
		end,
		-- or 'AppleSelectedInputSourcesChangedNotification'
		"com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"
	)

	-- Sync every second to avoid state desync due to missed event listeners
	self.indicatorSyncTimer = self.hs.timer.new(1, function()
		self:handleInputSourceChanged()
	end)

	-- Re-render when screen changes
	self.screenWatcher = self.hs.screen.watcher.new(function()
		self:update()
	end)

	-- Start all watchers
	self:start()

	-- Initial execution
	self:update()

	return self
end

-- Start all watchers
function obj:start()
	self.distributedNotification:start()
	self.indicatorSyncTimer:start()
	self.screenWatcher:start()
end

-- Stop all watchers
function obj:stop()
	self.distributedNotification:stop()
	self.indicatorSyncTimer:stop()
	self.screenWatcher:stop()
end

return obj

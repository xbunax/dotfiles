local M = {}
local function focus_other_screen() -- focuses the other screen
	local screen = hs.mouse.getCurrentScreen()
	local nextScreen = screen:next()
	local rect = nextScreen:fullFrame()
	local center = hs.geometry.rectMidPoint(rect)
	-- Adjust the center point: subtract from x to move left, subtract from y to move up
	center.x = center.x - 32
	center.y = center.y - 32
	hs.mouse.absolutePosition(center)
end

function get_window_under_mouse() -- from https://gist.github.com/kizzx2/e542fa74b80b7563045a
	local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
	local my_screen = hs.mouse.getCurrentScreen()
	return hs.fnutils.find(hs.window.orderedWindows(), function(w)
		return my_screen == w:screen() and my_pos:inside(w:frame())
	end)
end

function activate_other_screen()
	focus_other_screen()
	local win = get_window_under_mouse()
	if win then
		win:focus()
	else
		-- get first window on current screen
		local windows = hs.fnutils.filter(hs.window.orderedWindows(), function(w)
			return w:screen() == hs.mouse.getCurrentScreen()
		end)
		if #windows > 0 then
			windows[1]:focus()
		end
	end
end

function M:init()
	hs.hotkey.bind({ "shift", "cmd" }, "s", function() -- does the keybinding
		activate_other_screen()
	end)
end

return M

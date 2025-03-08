Drag = hs.loadSpoon("Drag")

local M = {}

function M:init()
	hs.hotkey.bind({ "cmd", "shift" }, "y", function()
		Darg:focusedWindowToSpace(29)
	end)
end

return M

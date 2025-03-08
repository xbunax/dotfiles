local M = {}

local screenWatcher = hs.caffeinate.watcher.new(function(event)
	if event == hs.caffeinate.watcher.screensDidSleep then
		-- 运行 shell 命令
		hs.execute(
			"/opt/homebrew/bin/aerospace list-windows --all --format '%{window-id}%{workspace}%{app-bundle-id}' --json >~/.config/aerospace/scripts/layout.json",
			true
		)
	end
end)

function M:init()
	screenWatcher:start()
end

return M

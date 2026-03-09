local globals = require("items.wallpaper.globals")
local helpers = require("items.wallpaper.helpers")
local components = require("items.wallpaper.components")

-- Key events
sbar.add("event", "request_bg")
sbar.add("event", "cycle_bg")
sbar.add("event", "select_bg")

components.bg:subscribe("request_bg", function(env)
	helpers.setAnchorText()
	local requested = env.REQUEST_BG == "true"

	components.bg:set({ popup = { drawing = requested } })
	components.bgAnchor:set({ popup = { drawing = requested } })
	components.previewAnchor:set({ popup = { drawing = requested } })

	local tbl = helpers.seekTbl(requested)
	helpers.entryToggle(tbl, false, requested)
end)

components.bg:subscribe("cycle_bg", function(env)
	if env.CYCLE == "next" then
		helpers.cycleNext()
	else
		helpers.cyclePrev()
	end
end)

local function setWallpaper()
	-- Get number of spaces
	-- local handle = io.popen("echo $(yabai -m query --spaces --display) | jq length $1")
	-- local result = handle:read("*a")
	-- handle:close()

	-- Cycle through spaces setting wallpaper for each
	local cmd = [[osascript -e "tell application \"System Events\" to set picture of every desktop to \"]]
		.. globals.selectedFilePath
		.. [[\" as POSIX file"]]
	-- .. "&& ~/.config/sketchybar/helpers/custom_bar_themes"

	os.execute(cmd)
end

components.bg:subscribe("select_bg", function(env)
	if env.SELECT == "true" then
		components.bgAnchor:set({
			icon = {
				string = "􀏆",
				-- drawing = true,
			},
			drawing = true,
		})
		components.bg:set({
			icon = {
				string = "􀏆",
				-- drawing = true,
			},
			drawing = true,
		})
		local tbl = helpers.getFocusedEntryTbl()
		helpers.entryToggle(tbl, true, true)

		globals.depth = globals.depth + 1
		print(globals.lockedFilePath)
		if globals.lockedFilePath then
			globals.depth = globals.depth - 1 < 1 and 1 or globals.depth - 1
			-- sbar.exec('skhd -k "ctrl - b"')
			setWallpaper()
		end
	else
		if globals.depth > 1 then
			-- Moved out one directory
			globals.depth = globals.depth - 1

			-- We just need the table
			local tbl = helpers.getFocusedEntryTbl()

			-- Unset highlight
			helpers.entryToggle(tbl, false, true)
			-- else
			-- sbar.exec('skhd -k "ctrl - b"')
		end
	end
end)

local globals = {}

globals.dCount = 4

-- The wallpaper directory is defined to have depth 0
globals.depth = 1

globals.entryMap = {
	push = function(v)
		globals.entryMap[#globals.entryMap + 1] = v
	end,
	pop = function()
		return table.remove(globals.entryMap, nil)
	end,
}

globals.selectedFilePath = ""
globals.lockedFilePath = false

return globals

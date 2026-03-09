local colors = require("colors")

local components = require("items.wallpaper.components")
local globals = require("items.wallpaper.globals")

local helpers = {}

helpers.getFocusedEntryTbl = function()
	return globals.depth == 1 and components.entries or globals.entryMap[globals.depth - 1]["DIR_FILES"]
end

function helpers.toggleTblItem(itm, visible)
	itm:set({ drawing = visible })
end

function helpers.setAnchorText()
	local tbl = components.entries

	if #tbl ~= 0 then
		local minIdx = tbl["SELECTED"] - tbl["OPT_SELECTED"] + 1
		local maxIdx = tbl["SELECTED"] + globals.dCount - tbl["OPT_SELECTED"]
		maxIdx = maxIdx > #tbl and #tbl or maxIdx

		local longest = ""

		for i = minIdx, maxIdx do
			local sbarItem = tbl[i]["SBAR_ITEM"]
			local name = sbarItem:query().label.value
			longest = #longest < #name and name or longest
		end

		components.previewAnchor:set({ label = { string = longest } })
	end
end

function helpers.loadTbl(tbl, isLoaded)
	local minIdx = tbl["SELECTED"] - tbl["OPT_SELECTED"] + 1
	local maxIdx = tbl["SELECTED"] + globals.dCount - tbl["OPT_SELECTED"]
	maxIdx = maxIdx > #tbl and #tbl or maxIdx

	for i = minIdx, maxIdx do
		local sbarItem = tbl[i]["SBAR_ITEM"]
		helpers.toggleTblItem(sbarItem, isLoaded)
	end

	if minIdx ~= 1 then
		helpers.toggleTblItem(tbl[minIdx - 1]["SBAR_ITEM"], false)
	end

	if maxIdx ~= #tbl then
		helpers.toggleTblItem(tbl[maxIdx + 1]["SBAR_ITEM"], false)
	end
end

-- Sets opens the file tree to the current depth if open is true
-- Else, we close to the current depth
function helpers.seekTbl(open)
	helpers.loadTbl(components.entries, open)

	for i = 1, #globals.entryMap do
		local tbl = globals.entryMap[i]
		local sbarItem = tbl["SBAR_ITEM"]

		sbarItem:query()
		sbarItem:set({ popup = { drawing = open } })

		if tbl["DIR_FILES"] ~= nil then
			helpers.loadTbl(tbl["DIR_FILES"], open)
		end
	end

	return helpers.getFocusedEntryTbl()
end

-- Helper function for the next function entryToggle
--
-- Focused: The current entry is hovered over by the user but
-- not selected yet
--
-- Locked: The current entry is selected by the user
local function setHighlight(entry, locked, focused)
	entry:set({
		label = { color = locked and colors.green or focused and colors.yellow or colors.white },
		popup = { drawing = focused },
	})
end

-- To be used after seekTbl. Sets the highlight of entries that
-- of all entries of lower depth giving a preview of a file path to
-- a wallpaper
function helpers.entryToggle(tbl, locked, focused)
	local target = tbl.getSelected()
	if target == nil then
		return
	end

	setHighlight(target["SBAR_ITEM"], locked, focused)

	if target["DIR_FILES"] ~= nil then
		helpers.entryToggle(target["DIR_FILES"], false, focused)
	else
		components.previewAnchor:set({ background = { drawing = focused } })

		if focused then
			globals.lockedFilePath = locked
			globals.selectedFilePath = target["FILE_PATH"]

			sbar.exec(
				os.getenv("BAR_NAME")
					.. ' --set widgets.background.preview background.image="'
					.. globals.selectedFilePath
					.. '"'
			)
		end
	end
end

function helpers.etLoad()
	while #globals.entryMap ~= 0 do
		globals.entryMap.pop()
	end

	local entryTbl = components.entries
	while true do
		local entry = entryTbl.getSelected()
		if entry == nil then
			break
		end

		globals.entryMap.push(entry)

		if entry["DIR_FILES"] ~= nil then
			entryTbl = entry["DIR_FILES"]
		else
			break
		end
	end
end

function helpers.cycleNext()
	local tbl = helpers.getFocusedEntryTbl()
	local idx = tbl["SELECTED"]

	if idx < #tbl then
		helpers.entryToggle(tbl, false, false)
		tbl["SELECTED"] = idx + 1

		local optIdx = tbl["OPT_SELECTED"]

		if optIdx ~= globals.dCount then
			tbl["OPT_SELECTED"] = optIdx + 1
		end

		helpers.etLoad()
		helpers.seekTbl(true)
		helpers.setAnchorText()
		helpers.entryToggle(tbl, false, true)
	end
end

function helpers.cyclePrev()
	-- load new entries if we scroll out of buffer
	local tbl = helpers.getFocusedEntryTbl()
	local idx = tbl["SELECTED"]

	if idx > 1 then
		helpers.entryToggle(tbl, false, false)
		tbl["SELECTED"] = idx - 1
		local optIdx = tbl["OPT_SELECTED"]

		if optIdx ~= 1 then
			tbl["OPT_SELECTED"] = optIdx - 1
		end

		helpers.etLoad()
		helpers.seekTbl(true)
		helpers.setAnchorText()
		helpers.entryToggle(tbl, false, true)
	end
end

return helpers

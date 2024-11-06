local colors = require("colors")
local settings = require("settings")
local globals = require("items.widgets.wallpaper.globals")

local components = {}

components.bgAnchor = sbar.add("item", "widgets.background.bgAnchor", {
	position = "right",
	width = 0,
	icon = {
		padding_right = 4,
		string = "􀵪",
		color = colors.with_alpha(colors.bg2, 0),
		font = {
			style = settings.font.style_map["Regular"],
			size = 20.0,
		},
	},
	update_freq = 180,
	popup = {
		align = "center",
		background = {
			drawing = true,
		},
	},
})

components.bg = sbar.add("item", "widgets.background", {
	position = "right",
	icon = {
		padding_right = 4,
		string = "􀵪",
		font = {
			style = settings.font.style_map["Regular"],
			size = 20.0,
		},
	},
	update_freq = 180,
	popup = {
		align = "center",
	},
})

sbar.add("bracket", "widgets.background.bracket", { components.bg.name }, {
	background = {
		color = colors.with_alpha(colors.bg2, colors.transparency),
		border_color = colors.black,
	},
})

sbar.add("item", "widgets.background.padding", {
	position = "right",
	width = settings.group_paddings,
})

components.previewAnchor = sbar.add("item", "widgets.background.previewAnchor", {
	position = "popup." .. components.bgAnchor.name,
	label = { string = "" },
	popup = {
		align = "left",
		drawing = true,
	},
})

components.previewer = sbar.add("item", "widgets.background.preview", {
	position = "popup." .. components.previewAnchor.name,
	background = { drawing = true },
})
sbar.exec(
	os.getenv("BAR_NAME") .. " --set widgets.background.preview background.image.scale=" .. settings.wallpaper.scale
)

components.entries = {}

local function genEntries(dir, name, pos, entryTbl)
	-- selected is the current entry in the table of wallpapers selected
	entryTbl["SELECTED"] = 1
	entryTbl.getSelected = function()
		if #entryTbl == 0 then
			return nil
		end
		return entryTbl[entryTbl["SELECTED"]]
	end

	-- curr_opt is the current entry that the user sees. This table has at most dCount entries
	entryTbl["OPT_SELECTED"] = 1

	local count = 0
	for file in io.popen('ls "' .. dir .. '" | grep .'):lines() do
		count = count + 1
		local optName = name .. "." .. file
		local filePath = dir .. "/" .. file

		-- Declare an object for either the wallpaper or directory that is read
		local option = sbar.add("item", optName, {
			position = "popup." .. pos,
			drawing = count < 5 and true or false,
			popup = { align = "right", drawing = false },
			label = { string = file },
		})

		if string.find(file, "%.") then
			-- We read in a wallpaper file
			local group = {}
			entryTbl[count] = group
			group["SBAR_ITEM"] = option
			group["FILE_PATH"] = filePath
			option:set({ label = { string = string.match(option:query().label.value, "(.-)%.") } })
		else
			-- We read in a directory
			local group = {}
			entryTbl[count] = group

			group["SBAR_ITEM"] = option
			group["DIR_FILES"] = {}

			option:set({ label = { string = "􀈖 " .. option:query().label.value } })

			genEntries(filePath, optName, option.name, group["DIR_FILES"])
		end
	end
end

genEntries(settings.wallpaper.path, "widgets.background", components.bg.name, components.entries)

return components

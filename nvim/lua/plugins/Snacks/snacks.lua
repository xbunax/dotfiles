-- local image = require("snacks.image.image")

vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })

--  vim.cmd [[hi SnacksNormal guibg=#293128]]
local highlight = {
	"RainbowRed",
	"RainbowYellow",
	"RainbowBlue",
	"RainbowOrange",
	"RainbowGreen",
	"RainbowViolet",
	"RainbowCyan",
}
vim.g.rainbow_delimiters = { highlight = highlight }

--dashboard animate
math.randomseed(os.time())

local function getRandomObject(array)
	local randomIndex = math.random(1, #array)
	return array[randomIndex]
end

local LOGOS = {
	-- { filename = "champloo.txt", height = 18, width = 61, animate = true },
	-- { filename = "thousand_sunny.txt", height = 33, width = 68, animate = false },
	{ filename = "test.txt", height = 28, width = 73, animate = true },
	-- { filename = "ed2.txt", height = 28, width = 73, animate = true },
}

local DIRPATH = "~/.config/nvim/lua/plugins/Snacks/"

local logo = getRandomObject(LOGOS)

local command
if logo.animate then
	command = "sh " .. DIRPATH .. "show.sh " .. DIRPATH .. "/" .. logo.filename
else
	command = "cat " .. DIRPATH .. "/" .. logo.filename
end

return {
	"snacks.nvim",
	opts = {

		terminal = {
			enabled = true,
		},
		indent = {
			enabled = true,
			filter = function(buf)
				return vim.g.snacks_indent ~= false
					and vim.b[buf].snacks_indent ~= false
					and vim.bo[buf].buftype == ""
					and (
						not vim.tbl_contains({
							"lazy",
							"help",
							"markdown",
						}, vim.bo[buf].filetype)
					)
				--  vim.bo[buf].buftype ~= "markdown"
			end,
			only_scope = false,
			scope = {
				enabled = true, -- enable highlighting the current scope
				priority = 200,
				char = "│",
				underline = true, -- underline the start of the scope
				only_current = false, -- only show scope in the current window
				hl = highlight,
			},
			hl = highlight,
			chunk = {
				enabled = true,
				only_current = false,
				priority = 200,
				hl = highlight,
				char = {
					corner_top = "╭",
					corner_bottom = "╰",
					horizontal = "─",
					vertical = "│",
					arrow = ">",
				},
			},
			blank = { hl = highlight },
		},
		input = { enabled = true },
		notifier = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		statuscolumn = { enabled = false }, -- we set this in options.lua
		-- toggle = { map = LazyVim.safe_keymap_set },
		picker = { enabled = true },
		words = { enabled = true },
		dashboard = {
			enabled = true,
			width = 70,
			sections = {
				{
					section = "terminal",
					cmd = command,
					height = logo.height,
					width = logo.width,
					padding = 1,
				},
				{
					pane = 2,
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
			},
			preset = {
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{ icon = "", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
					{
						icon = "󰒲 ",
						key = "l",
						desc = "Lazy",
						action = ":Lazy",
						enabled = package.loaded.lazy ~= nil,
					},
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
		image = {
			enabled = true,
			doc = {
				-- enable image viewer for documents
				-- a treesitter parser must be available for the enabled languages.
				enabled = true,
				-- render the image inline in the buffer
				-- if your env doesn't support unicode placeholders, this will be disabled
				-- takes precedence over `opts.float` on supported terminals
				inline = false,
				-- render the image in a floating window
				-- only used if `opts.inline` is disabled
				float = true,
				max_width = 80,
				max_height = 40,
				-- Set to `true`, to conceal the image text when rendering inline.
				conceal = false, -- (experimental)
			},
			convert = {
				notify = true, -- show a notification on error
				math = {
					font_size = "Large", -- see https://www.sascha-frank.com/latex-font-size.html
					-- for latex documents, the doc packages are included automatically,
					-- but you can add more packages here. Useful for markdown documents.
					packages = { "amsmath", "amssymb", "amsfonts", "amscd", "mathtools" },
				},
				mermaid = function()
					local theme = vim.o.background == "light" and "neutral" or "dark"
					return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "{scale}" }
				end,
				magick = {
					default = { "{src}[0]", "-scale", "1920x1080>" }, -- default for raster images
					vector = { "-density", 192, "{src}[0]" }, -- used by vector images like svg
					math = { "-density", 192, "{src}[0]", "-trim" },
					pdf = { "-density", 192, "{src}[0]", "-background", "white", "-alpha", "remove", "-trim" },
				},
			},
		},
	},
}

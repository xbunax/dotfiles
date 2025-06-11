-- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = "a" -- allow the mouse to be used in Nvim

-- Tab
vim.opt.tabstop = 4 -- number of visual spaces per TAB
vim.opt.softtabstop = 4 -- number of spacesin tab when editing
vim.opt.shiftwidth = 4 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of python

-- UI config
vim.opt.number = true -- show absolute number
vim.opt.relativenumber = true -- add numbers to each line on the left side
vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right
-- vim.opt.termguicolors = true        -- enabl 24-bit RGB color in the TUI
vim.opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint

-- Searching
vim.opt.incsearch = true -- search as characters are entered
vim.opt.hlsearch = false -- do not highlight matches
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered

-- color
vim.opt.termguicolors = true

-- UFO folding
vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.opt.spelllang = vim.opt.spelllang + "cjk"
vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#FF007C" })
vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = "#9B9B9B" })
vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = "#A0CC77" })
vim.g.lazyvim_picker = "snacks"
-- Lazy

-- theme
-- vim.o.background = "dark" -- or "light" for light mode
-- vim.cmd([[colorscheme gruvbox]])

-- vim.o.foldcolumn = '1' -- '0' is not bad
-- vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
-- vim.o.foldlevelstart = 99
-- vim.o.foldenable = true
-- 启用当前行高亮，并设置颜色为深灰色
vim.cmd("set cursorline")
--vim.cmd('hi CursorLine cterm=NONE ctermbg=235 guibg=DarkGrey')
--autosave
-- if vim.opt.auto_save then
--     vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
--         pattern = { "*" },
--         command = "silent! wall",
--         nested = true,
--     })
-- end

-- vim-tpipleline
vim.cmd([[let g:tpipeline_autoembed = 0]])
-- vim.cmd([[let g:tpipeline_statusline = '%!tpipeline#stl#line()']])
-- vim.cmd([[let g:tpipeline_statusline = '%f']])

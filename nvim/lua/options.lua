-- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.clipboard = 'unnamedplus' -- use system clipboard
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.mouse = 'a'               -- allow the mouse to be used in Nvim

-- Tab
vim.opt.tabstop = 4      -- number of visual spaces per TAB
vim.opt.softtabstop = 4  -- number of spacesin tab when editing
vim.opt.shiftwidth = 4   -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of python

-- UI config
vim.opt.number = true         -- show absolute number
vim.opt.relativenumber = true -- add numbers to each line on the left side
vim.opt.splitbelow = true     -- open new vertical split bottom
vim.opt.splitright = true     -- open new horizontal splits right
-- vim.opt.termguicolors = true        -- enabl 24-bit RGB color in the TUI
vim.opt.showmode = false      -- we are experienced, wo don't need the "-- INSERT --" mode hint

-- Searching
vim.opt.incsearch = true  -- search as characters are entered
vim.opt.hlsearch = false  -- do not highlight matches
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true  -- but make it case sensitive if an uppercase is entered

-- color
vim.opt.termguicolors = true
-- local term = os.getenv("TERM")
-- local xterm_version = os.getenv("XTERM_VERSION")
-- local konsole_profile_name = os.getenv("KONSOLE_PROFILE_NAME")
-- local vte_version = os.getenv("VTE_VERSION")
--
-- if term:match("^(rxvt|screen|interix|putty)(-.*)?$") then
--     vim.opt.termguicolors = false
-- elseif term:match("^(tmux|iterm|vte|gnome)(-.*)?$") then
--     vim.opt.termguicolors = true
-- elseif term:match("^(xterm)(-.*)?$") then
--     if xterm_version ~= '' or konsole_profile_name ~= '' or vte_version ~= '' then
--         vim.opt.termguicolors = true
--     else
--         vim.opt.termguicolors = false
--     end
--     -- 添加更多的条件判断
--     -- elseif term:match(...)

-- theme
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])

-- vim.o.foldcolumn = '1' -- '0' is not bad
-- vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
-- vim.o.foldlevelstart = 99
-- vim.o.foldenable = true
-- 启用当前行高亮，并设置颜色为深灰色
vim.cmd('set cursorline')
--vim.cmd('hi CursorLine cterm=NONE ctermbg=235 guibg=DarkGrey')
--autosave
-- if vim.opt.auto_save then
--     vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
--         pattern = { "*" },
--         command = "silent! wall",
--         nested = true,
--     })
-- end
--
-- vim.cmd[[
-- autocmd InsertLeave * write
-- ]]

-- typst-preview
-- vim.api.nvim_create_autocmd("CursorMoved", {
--     pattern = "*.typ",
--     command = "TypstPreviewFollowCursor"
-- })

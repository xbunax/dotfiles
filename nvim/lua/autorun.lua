-- pythons
local Terminal   = require('toggleterm.terminal').Terminal
local _runPython = Terminal:new({
    cmd = "/Users/xbunax/anaconda3/bin/python " .. vim.fn.expand("%"),
    -- hidden = false,
    close_on_exit = false,
})


local function runPython()
    _runPython:toggle()
end
vim.keymap.set("n", "<F5>", runPython)

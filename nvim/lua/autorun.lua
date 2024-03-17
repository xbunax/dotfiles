local Terminal   = require('toggleterm.terminal').Terminal

-- pythons
local _runPython = Terminal:new({
    cmd = "/opt/homebrew/Caskroom/miniconda/base/bin/python" .. vim.fn.expand("%"),
    -- hidden = false,
    close_on_exit = false,
})

local function runPython()
    _runPython:toggle()
end
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.keymap.set("n", "<F6>", runPython)
        -- vim.api.nvim_set_keymap("n", "<F5>",":lua runPython()<CR>", {noremap = true, silent = true})
    end
})

-- swift
local _runSwift = Terminal:new({
    cmd = "/usr/bin/swift " .. vim.fn.expand("%"),
    -- hidden = false,
    close_on_exit = false,
})
local function runSwift()
    _runSwift:toggle()
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "swift",
    callback = function()
        vim.keymap.set("n", "<F6>", runSwift)
    end
})

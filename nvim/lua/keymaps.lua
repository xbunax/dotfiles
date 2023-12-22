vim.api.nvim_set_keymap('n', 'Ff', ':SymbolsOutline<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', 'TT', ':NvimTreeFocus<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "nb", ":Navbuddy<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'RR', ':Lspsaga rename<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'FF', ':Lspsaga finder<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-q>', '<cmd>tabNext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-a>', '<cmd>tabclose<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-s>', '<cmd>w!<CR>', { noremap = true, silent = true })

--fzf
vim.keymap.set("n", "<c-P>", "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })


--scroll
-- 在你的 init.lua 或 init.vim 文件中添加以下内容

-- 创建一个自定义函数，用于向下滚动十行并将当前行居中显示
function scroll_down_and_center()
    --向下滚动十行
    vim.cmd('normal! 10j')
    -- 居中显示屏幕
    vim.cmd('normal! zz')
    --    local total_lines = vim.fn.line('$')
    --    local win_height = vim.fn.winheight(0)
    --
    --    -- 计算当前行在屏幕中的位置
    --    local cursor_line = vim.fn.line('.')
    --    local cursor_line_on_screen = vim.fn.line('w0')
    --
    --    -- 如果当前行在屏幕下面 1/4 的位置，则居中显示
    --    if cursor_line_on_screen > (3 * win_height / 4) then
    --        local new_cursor_line = cursor_line - (win_height / 2)
    --        -- 如果新的光标行小于1，则将其设置为1，以确保不越界
    --        new_cursor_line = math.max(new_cursor_line, 1)
    --        -- 设置新的光标行并居中显示
    --        vim.api.nvim_win_set_cursor(0, { new_cursor_line, 0 })
    --    end
end

function scroll_up_and_center()
    -- 向上滚动十行
    vim.cmd('normal! 10k')
    -- 居中显示屏幕
    vim.cmd('normal! zz')
end

-- 将"}"键映射为自定义函数
vim.keymap.set('n', '}', '<cmd>lua scroll_down_and_center()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '{', '<cmd>lua scroll_up_and_center()<CR>', { noremap = true, silent = true })


local runMyCommand = function()
    local fullpath = vim.fn.expand('%:p')
    local command = "typst-preview " ..
        vim.fn.shellescape(fullpath) ..
        " --partial-rendering"
    vim.fn.jobstart(command, {
        on_stdout = function(job_id, data, event)
            -- 处理标准输出
        end,
        on_stderr = function(job_id, data, event)
            -- 处理错误输出
        end,
        on_exit = function(job_id, data, event)
            -- 当作业退出时的处理
        end,
    })
    -- vim.api.nvim_command('terminal ' .. command)
end
-- local runMyCommand = function()
--     local fullpath = vim.fn.expand('%:p')
--     local command = "typst-preview"
--     local args = { vim.fn.shellescape(fullpath), "--partial-rendering" }
--
--     local function on_exit(code, signal)
--         -- 这里可以处理命令执行完成后的逻辑
--         handle:close()
--         if code ~= 0 then
--             print("Command exited with code " .. code .. " and signal " .. signal)
--         end
--     end
--
--     local handle = vim.loop.spawn(command, { args = args }, vim.schedule_wrap(on_exit))
-- end
vim.keymap.set('n', '<C-p>', runMyCommand, { noremap = true, silent = true })

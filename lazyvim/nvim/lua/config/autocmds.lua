-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "sh",
  callback = function()
    local filename = vim.fn.expand("%")
    local command = "/opt/homebrew/bin/shfmt -i 2 -ci " .. filename .. " > /dev/null"
    local result = vim.fn.system(command) -- 执行命令并获取输出

    -- 检查命令执行是否成功
    if vim.v.shell_error == 0 then
      -- 如果成功，显示成功消息
      vim.notify("format success" .. result, vim.log.levels.INFO)
    else
      -- 如果失败，显示错误消息和输出
      vim.notify("format failed" .. result, vim.log.levels.ERROR)
    end
  end,
})

vim.cmd([[
augroup my_highlight
  autocmd!
  autocmd FileType markdown highlight clear SpellBad
  autocmd FileType markdown highlight clear SpellCap
  autocmd FileType markdown highlight clear SpellLocal
  autocmd FileType markdown highlight clear SpellRare
augroup END
]])

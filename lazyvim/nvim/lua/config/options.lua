-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here

  -- Helper function for transparency formatting
  -- Helper function for transparency formatting
  local alpha = function()
    -- return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
  end
  -- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
  vim.g.neovide_transparency = 0.5
  vim.g.transparency = 0.8
  -- vim.g.neovide_background_color = "#0f1117" .. alpha()
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_window_blurred = true
  vim.g.neovide_show_border = false
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  -- vim.g.neovide_floating_z_height = 10
  -- vim.g.neovide_light_angle_degrees = 45
  -- vim.g.neovide_light_radius = 5
end

vim.cmd([[
  autocmd BufRead,BufNewFile *.typ setlocal filetype=typst
]])
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
-- vim.g.lazyvim_picker = "snacks"

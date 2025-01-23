return {
  "lervag/vimtex",
  lazy = false, -- lazy-loading will disable inverse search
  config = function()
    vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
    vim.g.vimtex_view_method = "skim" -- 设置 Skim 为预览器
    vim.g.vimtex_view_skim_sync = 1 -- 启用同步功能
    vim.g.vimtex_view_skim_activate = 1 -- 自动激活 Skim 窗口
    vim.g.vimtex_compiler_method = "latexmk" -- 使用 latexmk 编译器
    vim.g.vimtex_compiler_latexmk = {
      options = {
        "-pdf",
        "-interaction=nonstopmode",
        "-synctex=1",
      },
    }
    vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
  end,
  keys = {
    { "<localLeader>l", "", desc = "+vimtex", ft = "tex" },
  },
}

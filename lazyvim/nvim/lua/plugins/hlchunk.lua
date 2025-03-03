return {

  "shellRaining/hlchunk.nvim",
  -- lazy = true,
  -- event = { "BufReadPre", "BufNewFile" },
  ft = { "lua", "c", "c++" },
  enabled = function()
    return vim.bo.filetype ~= "markdown" -- 仅在非Markdown文件时启用插件
  end,
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        exclude_filetypes = {
          markdown = true,
        },
        chars = {
          horizontal_line = "─",
          vertical_line = "│",
          left_top = "╭",
          left_bottom = "╰",
          right_arrow = ">",
        },
        style = "#806d9c",
        -- style = {
        --   vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Whitespace")), "fg", "gui"),
        -- },
      },
      indent = {
        enable = true,
        chars = { "│", "¦", "┆", "┊" },
        use_treesitter = true,
      },
      blank = {
        enable = true,
      },
      line_num = {
        enable = true,
        style = "#806d9c",
        priority = 10,
        use_treesitter = false,
      },
    })
  end,
}

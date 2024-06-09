return {

  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
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
        enable = false,
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

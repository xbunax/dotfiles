return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    drag_and_drop = {
      enabled = true, ---@type boolean | fun(): boolean
      insert_mode = true, ---@type boolean | fun(): boolean
    },
    -- add options here
    -- or leave it empty to use the default settings
    filetypes = {
      tex = {
        use_absolute_path = false,
        relative_template_path = true,
        dir_path = function()
          -- return "figures/"
          return vim.fn.systemlist("git rev-parse --show-toplevel")[1] .. "/figures"
        end,
      },
    },
  },
  keys = {
    -- suggested keymap
    { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}

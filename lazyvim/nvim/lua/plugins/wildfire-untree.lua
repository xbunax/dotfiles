return {
  "gcmt/wildfire.vim",
  lazy = true,
  event = "VeryLazy",
  ft = { "typst" },
  config = function()
    vim.cmd([[
      let g:wildfire_objects = ["i'", 'i"', "i)", "i]", "i}", "ip", "it","i`","i$"]
      ]])
  end,
}

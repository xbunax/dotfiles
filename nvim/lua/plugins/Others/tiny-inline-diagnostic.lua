return {
  "rachartier/tiny-inline-diagnostic.nvim",
  -- event = "LspAttach", -- Or `LspAttach`
  priority = 3000, -- needs to be loaded in first
  branch = "main",
  init = function()
    vim.diagnostic.config({
      virtual_text = false,
      update_in_insert = true,
      virtual_lines = {
        -- only_current_line = true,
        highlight_whole_line = false,
      },
    })
  end,
  config = function()
    -- Default configuration
    require("tiny-inline-diagnostic").setup({
      preset = "ghost", -- Can be: "modern", "classic", "minimal", "ghost", "simple", "nonerdfont", "amongus"

      options = {
        -- Throttle the update of the diagnostic when moving cursor, in milliseconds.
        -- You can increase it if you have performance issues.
        -- Or set it to 0 to have better visuals.
        throttle = 0,

        -- The minimum length of the message, otherwise it will be on a new line.
        softwrap = 30,

        -- If multiple diagnostics are under the cursor, display all of them.
        multiple_diag_under_cursor = true,

        -- Enable diagnostic message on all lines.
        multilines = true,

        -- Show all diagnostics on the cursor line.
        show_all_diags_on_cursorline = true,

        -- Enable diagnostics on Insert mode. You should also se the `throttle` option to 0, as some artefacts may appear.
        enable_on_insert = true,
      },
    })
  end,
}

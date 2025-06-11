return {
  "chomosuke/typst-preview.nvim",
  -- lazy = false, -- or ft = 'typst'
  ft = "typst",
  version = "0.3.*",
  build = function()
    require("typst-preview").update()
  end,
  opts = {
    debug = false,

    -- Custom format string to open the output link provided with %s
    -- Example: open_cmd = 'firefox %s -P typst-preview --class typst-preview'
    open_cmd = nil,
    -- open_cmd = "/bin/zsh -c 'kitty @ launch --hold --type=os-window zsh -c \"awrit %s\"'",
    -- port = 8000,

    -- Setting this to 'always' will invert black and white in the preview
    -- Setting this to 'auto' will invert depending if the browser has enable
    -- dark mode
    invert_colors = "never",

    -- Whether the preview will follow the cursor in the source file
    follow_cursor = true,

    -- Provide the path to binaries for dependencies.
    -- Setting this will skip the download of the binary by the plugin.
    -- Warning: Be aware that your version might be older than the one
    -- required.
    dependencies_bin = {
      ["typst-preview"] = nil,
      ["websocat"] = nil,
    },

    -- This function will be called to determine the root of the typst project
    get_root = function(path_of_main_file)
      return vim.fn.fnamemodify(path_of_main_file, ":p:h")
    end,

    -- This function will be called to determine the main file of the typst
    -- project.
    get_main_file = function(path_of_buffer)
      return path_of_buffer
    end,
  },
}

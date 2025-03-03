-- local image = require("snacks.image.image")

vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })

--  vim.cmd [[hi SnacksNormal guibg=#293128]]
local highlight = {
  "RainbowRed",
  "RainbowYellow",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}
vim.g.rainbow_delimiters = { highlight = highlight }

--dashboard animate
math.randomseed(os.time())

local function getRandomObject(array)
  local randomIndex = math.random(1, #array)
  return array[randomIndex]
end

local LOGOS = {
  -- { filename = "champloo.txt", height = 18, width = 61, animate = true },
  -- { filename = "thousand_sunny.txt", height = 33, width = 68, animate = false },
  { filename = "test.txt", height = 28, width = 73, animate = true },
  -- { filename = "ed2.txt", height = 28, width = 73, animate = true },
}

local DIRPATH = "~/.config/lazyvim/nvim/lua/plugins/"

local logo = getRandomObject(LOGOS)

local command
if logo.animate then
  command = "sh " .. DIRPATH .. "show.sh " .. DIRPATH .. "/" .. logo.filename
else
  command = "cat " .. DIRPATH .. "/" .. logo.filename
end

return {
  "snacks.nvim",
  opts = {

    indent = {
      enabled = true,
      filter = function(buf)
        return vim.g.snacks_indent ~= false
          and vim.b[buf].snacks_indent ~= false
          and vim.bo[buf].buftype == ""
          and (
            not vim.tbl_contains({
              "lazy",
              "help",
              "markdown",
            }, vim.bo[buf].filetype)
          )
        --  vim.bo[buf].buftype ~= "markdown"
      end,
      only_scope = false,
      scope = {
        enabled = true, -- enable highlighting the current scope
        priority = 200,
        char = "│",
        underline = true, -- underline the start of the scope
        only_current = false, -- only show scope in the current window
        hl = highlight,
      },
      hl = highlight,
      chunk = {
        enabled = true,
        only_current = false,
        priority = 200,
        hl = highlight,
        char = {
          corner_top = "╭",
          corner_bottom = "╰",
          horizontal = "─",
          vertical = "│",
          arrow = ">",
        },
      },
      blank = { hl = highlight },
    },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false }, -- we set this in options.lua
    toggle = { map = LazyVim.safe_keymap_set },
    picker = { enabled = true },
    words = { enabled = true },
    dashboard = {
      enabled = true,
      width = 70,
      sections = {
        {
          section = "terminal",
          cmd = command,
          height = logo.height,
          -- width = logo.width,
          padding = 1,
        },
        {
          pane = 2,
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    image = {
      enabled = true,
      doc = {
        -- enable image viewer for documents
        -- a treesitter parser must be available for the enabled languages.
        enabled = true,
        -- render the image inline in the buffer
        -- if your env doesn't support unicode placeholders, this will be disabled
        -- takes precedence over `opts.float` on supported terminals
        inline = false,
        -- render the image in a floating window
        -- only used if `opts.inline` is disabled
        float = true,
        max_width = 80,
        max_height = 40,
        -- Set to `true`, to conceal the image text when rendering inline.
        conceal = false, -- (experimental)
      },
      convert = {
        notify = true, -- show a notification on error
        math = {
          font_size = "Large", -- see https://www.sascha-frank.com/latex-font-size.html
          -- for latex documents, the doc packages are included automatically,
          -- but you can add more packages here. Useful for markdown documents.
          packages = { "amsmath", "amssymb", "amsfonts", "amscd", "mathtools" },
        },
        mermaid = function()
          local theme = vim.o.background == "light" and "neutral" or "dark"
          return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "{scale}" }
        end,
        magick = {
          default = { "{src}[0]", "-scale", "1920x1080>" }, -- default for raster images
          vector = { "-density", 192, "{src}[0]" }, -- used by vector images like svg
          math = { "-density", 192, "{src}[0]", "-trim" },
          pdf = { "-density", 192, "{src}[0]", "-background", "white", "-alpha", "remove", "-trim" },
        },
      },
    },
  },
  -- stylua: ignore
  keys = {
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/", LazyVim.pick("grep"), desc = "Grep (Root Dir)" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    -- { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>U", function() Snacks.picker.undo() end, desc = "Undo Tree" },
    -- find
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" },
    { "<leader>fc", LazyVim.pick.config_files(), desc = "Find Config File" },
    { "<leader>ff", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    { "<leader>fF", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Files (git-files)" },
    { "<leader>fr", LazyVim.pick("oldfiles"), desc = "Recent" },
    { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent (cwd)" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    -- git
    { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
    -- Grep
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
    { "<leader>sg", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },
    { "<leader>sG", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
    { "<leader>sw", LazyVim.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
    { "<leader>sW", LazyVim.pick("grep_word", { root = false }), desc = "Visual selection or word (cwd)", mode = { "n", "x" } },
    -- search
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
    { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
    { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
    { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
    { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
    { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },
    -- ui
    { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
    -- LSP
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Picker Goto Definition" },
    { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Picker Goto Declaration" },
    { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "Picker References" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Picker Goto Implementation" },
    { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Picker Goto T[y]pe Definition" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
  },
}

-- local image = require("snacks.image.image")
return {
  "snacks.nvim",
  opts = {
    indent = { enabled = false },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = false }, -- we set this in options.lua
    toggle = { map = LazyVim.safe_keymap_set },
    picker = { enabled = true },
    words = { enabled = true },
    dashboard = {
      enabled = false,
      preset = {
        header = [[
                                                                         
                                                                       
         ████ ██████           █████      ██                     
        ███████████             █████                             
        █████████ ███████████████████ ███   ███████████   
       █████████  ███    █████████████ █████ ██████████████   
      █████████ ██████████ █████████ █████ █████ ████ █████   
    ███████████ ███    ███ █████████ █████ █████ ████ █████  
   ██████  █████████████████████ ████ █████ █████ ████ ██████ 
                                                                         
 ]],
      },
    },
    -- picker = {
    --   win = {
    --     input = {
    --       keys = {
    --         ["<a-c>"] = {
    --           "toggle_cwd",
    --           mode = { "n", "i" },
    --         },
    --       },
    --     },
    --   },
    --   actions = {
    --     ---@param p snacks.Picker
    --     toggle_cwd = function(p)
    --       local root = LazyVim.root({ buf = p.input.filter.current_buf, normalize = true })
    --       local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
    --       local current = p:cwd()
    --       p:set_cwd(current == root and cwd or root)
    --       p:find()
    --     end,
    --   },
    -- },
    image = { enabled = true },
  },
  -- stylua: ignore
  keys = {
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/", LazyVim.pick("grep"), desc = "Grep (Root Dir)" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    -- { "<leader><space>", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
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
  },
}

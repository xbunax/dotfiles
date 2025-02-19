math.randomseed(os.time())

local function getRandomObject(array)
  local randomIndex = math.random(1, #array)
  return array[randomIndex]
end

local LOGOS = {
  -- { filename = "champloo.txt", height = 18, width = 61, animate = true },
  -- { filename = "thousand_sunny.txt", height = 33, width = 68, animate = false },
  { filename = "ed.txt", height = 28, width = 73, animate = true },
  { filename = "ed2.txt", height = 28, width = 73, animate = true },
}

local DIRPATH = "~/.config/lazyvim/nvim/lua/plugins/"

return {
  "goolord/alpha-nvim",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    require("alpha.term")

    dashboard.opts.opts.noautocmd = true
    dashboard.section.terminal.opts.redraw = true

    local logo = getRandomObject(LOGOS)

    local command
    if logo.animate then
      command = "sh " .. DIRPATH .. "show.sh " .. DIRPATH .. "/" .. logo.filename
    else
      command = "cat " .. DIRPATH .. "/" .. logo.filename
    end

    dashboard.section.terminal.command = command
    dashboard.section.terminal.width = logo.width
    dashboard.section.terminal.height = logo.height
    dashboard.section.buttons.val = {
      dashboard.button("<leader>F", "  > Find file", ":lua LazyVim.pick()()<CR>"),
      dashboard.button("r", "  > Recent file", ":lua LazyVim.pick('oldfiles')()<CR>"),
      dashboard.button("s", "  > Settings", ":lua LazyVim.pick.config_files()()<CR>"),
      dashboard.button("q", "  > Quit NVIM", ":qa<CR>"),
    }

    dashboard.opts.layout = {
      { type = "padding", val = 3 },
      dashboard.section.terminal,
      { type = "padding", val = 3 },
      dashboard.section.buttons,
    }
    alpha.setup(dashboard.config)
  end,
}

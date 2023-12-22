return {
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                contrast = "soft",
                terminal_colors = true, -- add neovim terminal colors
                transparent_mode = true,
            })
        end
    }, -- Default options:
    --    config = function()
    --        require("gruvbox").setup({
    --           transparent_mode = true
    --        })
    --    end
    --    config = function()
    --    require("gruvbox").setup({
    --        terminal_colors = true, -- add neovim terminal colors
    --        undercurl = true,
    --        underline = true,
    --        bold = true,
    --        italic = {
    --            strings = true,
    --            emphasis = true,
    --            comments = true,
    --            operators = false,
    --            folds = true,
    --        },
    --        strikethrough = true,
    --        invert_selection = false,
    --        invert_signs = false,
    --        invert_tabline = false,
    --        invert_intend_guides = false,
    --        inverse = true, -- invert background for search, diffs, statuslines and errors
    --        contrast = "", -- can be "hard", "soft" or empty string
    --        palette_overrides = {},
    --        overrides = {},
    --        dim_inactive = false,
    --        transparent_mode = true,
    --    })
    --    end,
    --    vim.cmd("colorscheme gruvbox"),
    --    config = function()
    --        require("gruvbox").setup({
    --            -- palette_overrides = {
    --            --     bright_green = "#990000",
    --            -- }
    --            terminal_colors= true,
    --            --transparent_mode=true,
    --        })
    --    end

}

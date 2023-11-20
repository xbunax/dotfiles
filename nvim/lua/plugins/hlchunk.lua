return {

    "shellRaining/hlchunk.nvim",
    event = { "UIEnter" },
    config = function()
        require('hlchunk').setup({
            chunk = {
                chars = {
                    horizontal_line = "─",
                    vertical_line = "│",
                    left_top = "╭",
                    left_bottom = "╰",
                    right_arrow = ">",
                },
                style = "#806d9c",
            },
            indent = {
                chars = { "│", "¦", "┆", "┊", },
                use_treesitter = false,
            },
            blank = {
                enable = false,
            },
            line_num = {
                use_treesitter = true,
            },
        })
    end



}

return {
    "nvim-tree/nvim-tree.lua",
    dependenices = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("nvim-tree").setup({
            sort = {
                sorter = "case_sensitive",
            },
            view = {
                width = 30,
            },
            renderer = {
                group_empty = true,
            },
            filters = {
                dotfiles = true,
            },
        })
    end
}

return {
    "nvim-tree/nvim-tree.lua",
    dependenices = { "nvim-tree/nvim-web-devicons" },
    keys = { "TT" },
    lazy = true,
    config = function()
        vim.api.nvim_set_keymap('n', 'TT', ':NvimTreeFocus<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', 'TC', ':NvimTreeClose<CR>', { noremap = true, silent = true })
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

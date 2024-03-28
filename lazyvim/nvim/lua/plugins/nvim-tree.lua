return {
    "nvim-tree/nvim-tree.lua",
    dependenices = { "nvim-tree/nvim-web-devicons" },
    keys = { "TT" },
    lazy = true,
    config = function()
        vim.api.nvim_set_keymap('n', 'TT', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', 'TF', ':NvimTreeFocus<CR>', { noremap = true, silent = true })
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

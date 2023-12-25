return {
    "sustech-data/wildfire.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = {"c","cpp","lua","python","rust","toml","matlab","zsh"},
    -- cond = function()
    --     -- local fileType = vim.bo.filetype
    --     if vim.bo.filetype == "typst" then
    --         return false
    --     else
    --         return true
    --     end
    -- end,
    config = function()
        require("wildfire").setup(
            {
                surrounds = {
                    { "(", ")" },
                    { "{", "}" },
                    { "<", ">" },
                    { "[", "]" },
                    { "$", "$" },
                    { "`", "`" },
                },
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    node_decremental = "<BS>",
                },
                filetype_exclude = { "qf","typst" }, --keymaps will be unset in excluding filetypes
            }
        )
    end,
}

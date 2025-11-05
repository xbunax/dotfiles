return {
    "SmiteshP/nvim-navbuddy",
    priority = 100,
    dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim"
    },
    -- event=":Navbuddy",
    -- keys = { "NN" },
    -- lazy = true,
    opts = { lsp = { auto_attach = true } },
    keys={
		{
			"<leader>cs",
            ":Navbuddy<CR>",
			desc = "Navbuddy",
		},
    }
    -- config = function()
    --     -- vim.api.nvim_set_keymap("n", "nb", ":Navbuddy<CR>", { noremap = true, silent = true })
    --     -- vim.api.nvim_set_keymap('n', 'NN', '<cmd>Navbuddy<CR>', { noremap = true, silent = true })
    -- end
}

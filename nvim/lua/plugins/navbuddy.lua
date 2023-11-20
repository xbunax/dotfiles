return {
    "SmiteshP/nvim-navbuddy",
    priority=100,
    dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim"
    },
    opts = { lsp = { auto_attach = true } }
}

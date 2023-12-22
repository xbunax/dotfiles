return {
    "folke/neodev.nvim",
    opts = {},
    config = function()
        require("neodev").setup({
            -- add any options here, or leave empty to use the default settings
        })

        -- then setup your lsp server as usual
        local lspconfig = require('lspconfig')

        -- example to setup lua_ls and enable call snippets
        lspconfig.lua_ls.setup({
            settings = {
                Lua = {
                    completion = {
                        callSnippet = "Replace"
                    }
                }
            }
        })
    end
}

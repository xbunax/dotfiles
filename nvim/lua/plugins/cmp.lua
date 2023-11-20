return
{
    "hrsh7th/nvim-cmp",
    after = "SirVer/ultisnips",
    dependencies = {
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-calc",
        -- "andersevenrud/cmp-tmux",
        {
            "onsails/lspkind.nvim",
            lazy = false,
            config = function()
                require("lspkind").init()
            end
        },
        {
            "quangnguyen30192/cmp-nvim-ultisnips",
            config = function()
                -- optional call to setup (see customization section)
                require("cmp_nvim_ultisnips").setup {}
            end,
        }
        -- "L3MON4D3/LuaSnip",
    },


    config = function()
        local cmp = require 'cmp'
        local lspkind = require("lspkind")
        cmp.setup({
            snippet = {
                -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                    --vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                    -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                    --vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                -- documentation = cmp.config.window.bordered(),
            },

            mapping = {
                -- 选择上一个
                ['<C-k>'] = cmp.mapping.select_prev_item(),
                -- 选择下一个
                ['<Tab>'] = cmp.mapping.select_next_item(),
                -- 出现补全
                ['<A-.>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
                -- 取消补全
                ['<A-,>'] = cmp.mapping({
                    i = cmp.mapping.abort(),
                    c = cmp.mapping.close(),
                }),

                -- 确认使用某个补全项
                ['<CR>'] = cmp.mapping.confirm({
                    select = true,
                    behavior = cmp.ConfirmBehavior.Replace
                }),

                -- 向上翻页
                ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
                -- 向下翻页
                ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
            },
            -- mapping = cmp.mapping.preset.insert({
            --     ['<C-b>'] = cmp.mapping.select_prev_item(),
            --     ['Tab'] = cmp.mapping.select_next_item(),
            --     ['<C-Space>'] = cmp.mapping.complete(),
            --     ['<C-e>'] = cmp.mapping.abort(),
            --     ['<CR>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            -- }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'vsnip' },
                -- For vsnip users.
                -- { name = 'luasnip' }, -- For luasnip users.
                -- { name = 'ultisnips' }, -- For ultisnips users.
                -- { name = 'snippy' }, -- For snippy users.
            }, {
                { name = 'buffer' },
            })
        })
        formatting = {
            format = lspkind.cmp_format({
                mode = 'symbol',       -- show only symbol annotations
                maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

                -- The function below will be called before any actual modifications from lspkind
                -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))

            })
        }
        -- Set configuration for specific filetype.
        cmp.setup.filetype('gitcommit', {
            sources = cmp.config.sources({
                { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
            }, {
                { name = 'buffer' },
            })
        })

        -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            })
        })

        -- Set up lspconfig.

        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
        require('lspconfig')['pylsp'].setup {
            capabilities = capabilities
        }
        require('lspconfig')['lua_ls'].setup {
            capabilities = capabilities
        }
    end
}

return {
  "neovim/nvim-lspconfig",

  opts = {
    -- options for vim.diagnostic.config()
    diagnostics = {
      underline = false,
      update_in_insert = false,
      virtual_text = false,
      -- virtual_text = {
      --   spacing = 4,
      --   source = "if_many",
      --   prefix = "●",
      -- },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
          [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
          [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
          [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
        },
      },
    },
    -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
    -- Be aware that you also will need to properly configure your LSP server to
    -- provide the inlay hints.
    inlay_hints = {
      enabled = true,
    },
    -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
    -- Be aware that you also will need to properly configure your LSP server to
    -- provide the code lenses.
    codelens = {
      enabled = false,
    },
    -- add any global capabilities here
    capabilities = {},
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    -- LSP Server Settings
    servers = {
      lua_ls = {
        -- mason = false, -- set to false if you don't want this server to be installed with mason
        -- Use this to add any additional keymaps
        -- for specific lsp servers
        -- keys = {},
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            codeLens = {
              enable = true,
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      },
      tinymist = {
        single_file_support = true,
        root_dir = function()
          return vim.fn.getcwd()
        end,
        settings = {
          exportPdf = "onType",
          outputPath = "$root/target/$dir/$name",
          formatterMode = "typstyle",
        },
      },
      matlab_ls = {
        single_file_support = false,
        installPath = "/Applications/MATLAB_R2024a.app",
        indexWorkspace = true,
        telemetry = true,
        root_dir = function()
          return vim.fn.getcwd()
        end,
      },
    },
    -- you can do any additional lsp server setup here
    -- return true if you don't want this server to be setup with lspconfig
    setup = {
      -- example to setup with typescript.nvim
      -- tsserver = function(_, opts)
      --   require("typescript").setup({ server = opts })
      --   return true
      -- end,
      -- Specify * to use this function as a fallback for any server
      -- ["*"] = function(server, opts) end,
    },
  },
}

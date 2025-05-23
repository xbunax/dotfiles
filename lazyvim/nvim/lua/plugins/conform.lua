return {
  "stevearc/conform.nvim",
  opts = function()
    local opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_fallback = true, -- not recommended to change
      },
      formatters_by_ft = {
        lua = { "stylua" },
        typst = { "typstyle" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        zsh = { "shfmt" },
        cpp = { "clang-format" },
        python = { "black" },
        markdown = { "prettier" },
        toml = { "taplo" },
      },
      formatters = {
        injected = { options = { ignore_errors = true } },
        shfmt = {
          prepend_args = { "-i", "2", "-ci" },
        },
      },
    }
    return opts
  end,
}

return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua", lsp_format = "fallback" },
			zsh = { "shfmt", lsp_format = "fallback" },
			-- Conform will run multiple formatters sequentially
			python = { formatters = "black", lsp_format = "fallback" },
			-- You can customize some of the format options for the filetype (:help conform.format)
			rust = { "rustfmt", lsp_format = "fallback" },

			-- Conform will run the first available formatter
			-- javascript = { "prettierd", "prettier", stop_after_first = true },
		},
		formatters = {
			stylua = {
				command = "stylua",
				args = {
					"--column-width",
					"500",
					"--stdin-filepath",
					"$FILENAME",
					"-",
				},
				stdid = true,
			},
		},
	},
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true })
			end,
			mode = "",
			desc = "format",
		},
	},
}

return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	opts = {
		outline = {
			-- layout = "float",
			-- max_height = 0.6,
			-- left_width = 0.3,
		},
	},
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- optional
		"nvim-tree/nvim-web-devicons", -- optional
	},
}

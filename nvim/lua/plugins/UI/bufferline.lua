return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		require("bufferline").setup({
			options = {
				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},
			},
		})
	end,
    keys={
        {"<leader>bp","<cmd>BufferLinePickClose<CR>",desc="close buffer tab with pick"}
    }
}

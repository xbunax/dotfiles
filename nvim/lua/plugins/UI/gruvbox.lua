return {
	-- add gruvbox
	{
		"ellisonleao/gruvbox.nvim",
		config = function()
			require("gruvbox").setup({
				contrast = "soft",
				terminal_colors = true,
				transparent_mode = true,
			})
		end,
	},
}

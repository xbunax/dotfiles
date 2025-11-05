return {
	"kiyoon/jupynium.nvim",
	-- build = "pip3 install --user .",
	build = "uv pip install . --python=$HOME/.virtualenvs/jupynium/bin/python",
	-- build = "conda run --no-capture-output -n jupynium pip install .",
	dependencies = {
		"rcarriga/nvim-notify", -- optional
		"stevearc/dressing.nvim", -- optional, UI for :JupyniumKernelSelect
	},
	config = function()
		require("jupynium").setup({
			jupynium_file_pattern = { "*.ju.*", "*.ipynb" },
			python_host = vim.g.python3_host_prog or "python3",
		})
	end,
}

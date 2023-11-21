local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)


-- Example using a list of specs with the default options
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
	require("plugins.navbuddy"),
	require("plugins.mason"),
	require("plugins.gruvbox"),
	--require("plugins.lspconfig")
	require("plugins.cmp"),
	require("plugins.hlchunk"),
	require("plugins.treesister"),
	--require("plugins.minianimate")
	require("plugins.neoscroll"),
	require("plugins.winbar"),
	require("plugins.dressing"),
	require("plugins.autopaires"),
	require("plugins.noice"),
	--require("plugins.ufo"),
	require("plugins.telescope"),
	require("plugins.toggleterm"),
	require("plugins.scrollbar"),
	require("plugins.symbols-outline"),
	require("plugins.vim-illuminate"),
	require("plugins.bufferline"),
	require("plugins.lualine"),
	require("plugins.leap"),
	require("plugins.wildfire"),
	require("plugins.alternate"),
    require("plugins.nvim-tree"),
    require("plugins.lspsaga"),
    require("plugins.markdown-pre"),
    require("plugins.dashboard"),
    require("plugins.oil"),
    require("plugins.fzf-lua"),
    require("plugins.fzf"),
    require("plugins.comment"),
    require("plugins.lazygit"),
	--require("plugins.neotree"),
})

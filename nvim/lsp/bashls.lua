return {
	cmd = { "bash-language-server", "start" },
	filetypes = { "bash", "sh", "zsh" },
	settings = {
		bashIde = {
			globPattern = "*@(.sh|.inc|.zsh|.bash|.command)",
		},
	},
}

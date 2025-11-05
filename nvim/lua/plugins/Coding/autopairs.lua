return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = true,
	opts = {
		ignored_next_char = [=[[%w%%%'%[%"%.%`]]=],
	},
	-- use opts = {} for passing setup options
	-- this is equivalent to setup({}) function
}


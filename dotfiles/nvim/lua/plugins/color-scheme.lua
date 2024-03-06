return {
	{
		"edeneast/nightfox.nvim",
		opts = {
			options = {
				-- transparent = true,
			},
		},
	},
	{
		"LazyVim/LazyVim",
		dependencies = {
			"rcarriga/nvim-notify",
			opts = {
				-- this fixes an issue when setting transparent BG
				background_colour = "#000000",
			},
		},
		opts = {
			colorscheme = "nightfox",
		},
	},
}

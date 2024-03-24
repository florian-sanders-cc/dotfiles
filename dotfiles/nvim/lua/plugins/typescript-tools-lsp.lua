-- vim.lsp.set_log_level("debug")
return {
	{
		"pmizio/typescript-tools.nvim",
		enabled = false,
		opts = {},
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"neovim/nvim-lspconfig",
				opts = {
					servers = {
						tsserver = {},
					},
				},
			},
		},
		event = "VeryLazy",
	},
}

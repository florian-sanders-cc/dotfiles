return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				nixd = { enabled = true },
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				nix = { "nixfmt" },
			},
		},
	},
}

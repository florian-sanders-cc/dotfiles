-- vim.lsp.set_log_level("debug")
if true then
	return {}
end
return {
	{
		"pmizio/typescript-tools.nvim",
		enabled = true,
		opts = {
			tsserver = {
				fallbackPath = string.gsub(
					vim.fn.system("which tsserver"),
					"/bin/tsserver",
					"/lib/node_modules/typescript/lib/tsserver.js"
				),
			},
			preferences = {
				quotePreference = "single",
				importModuleSpecifierEnding = "js",
			},
		},
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

-- vim.lsp.set_log_level("debug")
return {
	"neovim/nvim-lspconfig",
	---@class PluginLspOpts
	opts = {
		servers = {
			---@type lspconfig.options.tsserver
			tsserver = {
				settings = {
					implicitProjectConfiguration = { checkJs = true, allowJs = true },
					fallbackPath = string.gsub(
						vim.fn.system("which tsserver"),
						"/bin/tsserver",
						"/lib/node_modules/typescript/lib/tsserver.js"
					),
					importModuleSpecifierEnding = "js",
					tsserver_plugins = {},
					javascript = {
						validate = {
							enabled = true,
						},
						preferences = {
							quoteStyle = "single",
							renameMatchingJsxTags = true,
						},
						format = {
							enable = true,
							semicolons = "insert",
							insertSpaceBeforeFunctionParenthesis = true,
							insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
						},
						suggest = {
							completeFunctionCalls = false,
						},
						updateImportsOnFileMove = true,
						preferGoToSourceDefinition = true,
					},
				},
			},
		},
	},
}

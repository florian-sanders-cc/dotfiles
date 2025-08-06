return {
	"neovim/nvim-lspconfig",
	opts = function(_, opts)
		opts.diagnostics.virtual_text = false
		opts.servers.vtsls.settings.vtsls = {
			typescript = {
				tsserver = {
					maxTsServerMemory = 8192,
				},
				preferences = {
					includePackageJsonAutoImports = "off",
					importModuleSpecifier = "relative",
					importModuleSpecifierEnding = "js",
					includeCompletionsForImportStatements = true,
					allowIncompleteCompletions = false,
				},
			},
			javascript = {
				tsserver = {
					maxTsServerMemory = 8192,
				},
				preferences = {
					includePackageJsonAutoImports = "off",
					importModuleSpecifier = "relative",
					importModuleSpecifierEnding = "js",
					includeCompletionsForImportStatements = true,
					allowIncompleteCompletions = false,
				},
			},
			experimental = {
				completion = {
					enableServerSideFuzzyMatch = true,
					entriesLimit = 50,
				},
			},
		}
	end,
}

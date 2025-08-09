return {
	"neovim/nvim-lspconfig",
	opts = function(_, opts)
		opts.diagnostics.virtual_text = false
		opts.servers.vtsls.settings = {
			tsserver = {
				maxTsServerMemory = 8192,
			},
			experimental = {
				completion = {
					enableServerSideFuzzyMatch = true,
					entriesLimit = 50,
				},
			},
			typescript = {
				preferences = {
					importModuleSpecifier = "relative",
					includePackageJsonAutoImports = "off",
					useAliasesForRenames = false,
					format = {
						enable = false,
					},
				},
			},
			javascript = {
				preferences = {
					importModuleSpecifier = "relative",
					includePackageJsonAutoImports = "off",
					useAliasesForRenames = false,
					format = {
						enable = false,
					},
				},
			},
		}
	end,
}

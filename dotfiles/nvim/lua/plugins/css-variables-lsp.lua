if true then
	return {}
end
return {
	"neovim/nvim-lspconfig",
	---@class PluginLspOpts
	opts = {
		css_variables = {
			cssVariables = {
				lookupFiles = { "**/*.less", "**/*.scss", "**/*.sass", "**/*.css" },
			},
		},
	},
}

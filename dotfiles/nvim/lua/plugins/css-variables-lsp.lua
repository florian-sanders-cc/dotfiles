return {
	"neovim/nvim-lspconfig",
	---@class PluginLspOpts
	opts = {
		setup = {
			css_variables = function(_, opts)
				opts.filetypes =
					{ "typescript", "javascript", "javascriptreact", "typescriptreact", "css", "scss", "less" }
			end,
		},
		servers = {
			css_variables = {
				blacklistFolders = {
					"**/.cache",
					"**/.DS_Store",
					"**/.git",
					"**/.hg",
					"**/.next",
					"**/.svn",
					"**/bower_components",
					"**/CVS",
					"**/dist",
					"**/node_modules",
					"**/tests",
					"**/tmp",
				},
				lookupFiles = { "**/*.less", "**/*.scss", "**/*.sass", "**/*.css" },
			},
		},
	},
}

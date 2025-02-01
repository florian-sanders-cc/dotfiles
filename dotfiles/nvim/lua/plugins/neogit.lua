return {
	"NeogitOrg/neogit",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration
	},
	keys = {
		{ "<leader>gn", "<cmd>Neogit<CR>", mode = { "n" }, desc = "Open current status and diff" },
	},
	config = true,
}

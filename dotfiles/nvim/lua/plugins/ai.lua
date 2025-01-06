return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		{
			"<Leader>ae",
			"<cmd>CodeCompanionActions<cr>",
			mode = { "n", "v" },
			{ noremap = true, silent = true },
			desc = "CodeCompanionActions",
		},
		-- { "v", "<Leader>ae", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true } },
		{
			"<Leader>ac",
			"<cmd>CodeCompanionChat Toggle<cr>",
			mode = { "n", "v" },
			{ noremap = true, silent = true },
			desc = "CodeCompanionChat",
		},
		-- { "v", "<Leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true } },
		{
			"<Leader>aa",
			"<cmd>CodeCompanionChat Add<cr>",
			mode = { "v" },
			{ noremap = true, silent = true },
			desc = "CodeCompanionChat Add",
		},
	},
	config = true,
}

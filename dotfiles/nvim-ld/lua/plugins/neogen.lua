return {
	"danymat/neogen",
	config = true,
	lazy = true,
	keys = {
		{
			"<leader>nf",
			function()
				require("neogen").generate()
			end,
			mode = { "n" },
			desc = "Generate docs",
		},
		{
			"<C-l>",
			function()
				require("neogen").jump_next()
			end,
			mode = { "i" },
			desc = "Go to next doc",
		},
		{
			"<C-h>",
			function()
				require("neogen").jump_prev()
			end,
			mode = { "i" },
			desc = "Go to prev doc",
		},
	},
}

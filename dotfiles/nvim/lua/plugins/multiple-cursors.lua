return {
	"brenton-leighton/multiple-cursors.nvim",
	version = "*", -- Use the latest tagged version
	opts = {}, -- This causes the plugin setup function to be called
	keys = {
		{
			"<M-j>",
			"<Cmd>MultipleCursorsAddDown<CR>",
			mode = { "n", "x" },
			desc = "Add cursor and move down",
		},
		{
			"<M-k>",
			"<Cmd>MultipleCursorsAddUp<CR>",
			mode = { "n", "x" },
			desc = "Add cursor and move up",
		},

		{
			"<C-Up>",
			"<Cmd>MultipleCursorsAddUp<CR>",
			mode = { "n", "i", "x" },
			desc = "Add cursor and move up",
		},
		{
			"<C-Down>",
			"<Cmd>MultipleCursorsAddDown<CR>",
			mode = { "n", "i", "x" },
			desc = "Add cursor and move down",
		},
		{
			"<M-a>",
			"<Cmd>MultipleCursorsAddMatches<CR>",
			mode = { "n", "x" },
			desc = "Add cursors to cword",
		},
		{
			"<M-D>",
			"<Cmd>MultipleCursorsAddMatchesV<CR>",
			mode = { "n", "x" },
			desc = "Add cursors to cword in previous area",
		},

		{
			"<M-n>",
			"<Cmd>MultipleCursorsJumpNextMatch<CR>",
			mode = { "n", "x" },
			desc = "Add cursor and jump to next cword",
		},

		{ "<M-ml>", "<Cmd>MultipleCursorsLock<CR>", mode = { "n", "x" }, desc = "Lock virtual cursors" },
	},
}

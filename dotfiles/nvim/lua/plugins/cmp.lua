return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"dcampos/cmp-emmet-vim",
		"mattn/emmet-vim",
		"hrsh7th/cmp-emoji",
	},
	opts = function(_, opts)
		local newSources = {
			{ name = "emoji" },
			-- { name = "emmet_vim" },
		}

		for _, value in pairs(newSources) do
			table.insert(opts.sources, value)
		end
	end,
}

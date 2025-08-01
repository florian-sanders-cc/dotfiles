return {
	"folke/snacks.nvim",
	opts = function(_, opts)
		-- Extend the existing opts with your indent configuration
		opts.indent = vim.tbl_deep_extend("force", opts.indent or {}, {
			indent = {
				enabled = true,
				char = "‧", -- dotted line character
				only_current = true,
			},
			chunk = {
				enabled = true, -- enable chunk rendering with curved borders
				only_current = true,
				char = {
					corner_top = "╭", -- curved top corner
					corner_bottom = "╰", -- curved bottom corner
					horizontal = "", -- horizontal line
					vertical = "│", -- vertical line
					arrow = "", -- arrow for chunk indication
				},
			},
		})

		return opts
	end,
}

return {
	"echasnovski/mini.diff",
	version = false,
	config = function()
		require("mini.diff").setup({
			-- Customize mini.diff options here if needed
			view = {
				style = "sign", -- Options: 'sign', 'number', 'background'
			},
		})
	end,
}

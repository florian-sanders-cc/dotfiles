vim.opt.termguicolors = true
if true then
	return {}
end
return {
	"NvChad/nvim-colorizer.lua",
	lazy = false,
	opts = {
		user_default_options = {
			mode = "background",
			names = false,
		},
	},
}

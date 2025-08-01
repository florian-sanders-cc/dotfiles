-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- not sure this is still necessary, TODO: check
vim.opt.clipboard = "unnamedplus"
vim.g.root_spec = { ".git", "cwd" }
vim.g.markdown_fenced_languages = {
	"ts=typescript",
}
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = true

vim.lsp.set_log_level("off")
vim.opt.laststatus = 0
vim.opt.list = false
vim.opt.listchars = ""

if vim.g.neovide then
	vim.o.linespace = 5
	vim.g.neovide_padding_top = 20
	vim.g.neovide_padding_bottom = 20
	vim.g.neovide_padding_right = 20
	vim.g.neovide_padding_left = 20

	vim.g.neovide_cursor_trail_size = 0.1
	vim.g.neovide_scroll_animation_length = 0.1
	vim.g.neovide_cursor_vfx_mode = "pixiedust"

	vim.g.neovide_profiler = false
	vim.o.guifont = "JetbrainsMonoNL Nerd Font Mono"
end

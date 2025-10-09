-- Alacritty integration for dynamic padding control
-- Removes padding when Neovim starts, restores it when exiting

-- Detect if running in Alacritty
local function is_alacritty()
  return vim.env.ALACRITTY_SOCKET ~= nil or vim.env.ALACRITTY_LOG ~= nil
end

if is_alacritty() then
  -- Remove padding when Neovim starts
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.fn.system("alacritty msg config 'window.padding.x=0' 'window.padding.y=0'")
    end,
  })

  -- Restore padding when Neovim exits
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      vim.fn.system("alacritty msg config 'window.padding.x=10' 'window.padding.y=10'")
    end,
  })
end

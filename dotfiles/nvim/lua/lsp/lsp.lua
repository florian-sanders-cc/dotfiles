vim.api.nvim_create_user_command("SelectTSVersion", function()
  local clients = vim.lsp.get_clients({ name = "vtsls" })
  if #clients == 0 then
    vim.notify("No vtsls client found", vim.log.levels.ERROR)
    return
  end
  local vtslsClient = clients[1]
  vtslsClient:exec_cmd({
    command = "typescript.selectTypeScriptVersion",
    title = "Select TypeScript version",
  })
end, {})

require("inc_rename").setup({
  input_buffer_type = nil, -- Use inc_rename's default input
})

vim.lsp.enable({ "nil_ls", "gopls", "lua_ls", "rust_analyzer", "marksman", "eslint", "vtsls", "json-ls", "copilot" })
vim.diagnostic.config({
  virtual_lines = { current_line = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "󰌵",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})

-- LSP keymaps are now consolidated in plugin/keymaps.lua

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event)
    Snacks.rename.on_rename_file(event.data.from, event.data.to)
  end,
})

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
  input_buffer_type = "snacks",
})

vim.lsp.enable({ "nil_ls", "gopls", "lua_ls", "rust_analyzer", "marksman", "eslint", "vtsls" })
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

vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set({ "n", "v" }, "<leader>cA", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "source" },
      diagnostics = {},
    },
  })
end, { desc = "Source Action" })
vim.keymap.set({ "n", "v" }, "<leader>cr", ":IncRename ", { desc = "Rename" })

-- vtsls-specific commands
vim.keymap.set("n", "gS", function()
  local clients = vim.lsp.get_clients({ name = "vtsls" })
  if #clients > 0 then
    local client = clients[1]
    clients[1]:exec_cmd({
      command = "typescript.goToSourceDefinition",
      arguments = {
        vim.uri_from_bufnr(0),
        vim.lsp.util.make_position_params(0, client.offset_encoding).position,
      },
    })
  else
    vim.lsp.buf.declaration()
  end
end, { desc = "Go to Source Definition" })

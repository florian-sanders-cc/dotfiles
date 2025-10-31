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

-- Delete default Neovim 0.10+ LSP keymaps (created in vim/_defaults.lua)
-- These are global keymaps that conflict with our custom gr mapping
pcall(vim.keymap.del, "n", "grr")
pcall(vim.keymap.del, "n", "gra")
pcall(vim.keymap.del, "n", "grn")
pcall(vim.keymap.del, "n", "gri")
pcall(vim.keymap.del, "n", "grt")

vim.lsp.enable({
  "nil_ls",
  "gopls",
  "lua_ls",
  "rust_analyzer",
  "marksman",
  "eslint",
  "vtsls",
  "json-ls",
  "html-ls",
  "gh-actions-ls",
})

vim.diagnostic.config({
  float = {
    format = function(original_diag)
      return string.format("  %s   \n  ", original_diag.message)
    end,
    header = "",
    prefix = function(diagnostic)
      return string.format("  \n  %s | %s  \n", diagnostic.source, diagnostic.code), "Comment"
    end,
    suffix = "",
  },
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

vim.keymap.set({ "n", "v" }, "D", vim.diagnostic.open_float, { desc = "LSP: Open Diagnostics" })
vim.keymap.set({ "n", "v" }, "]d", function()
  vim.diagnostic.goto_next({ float = true })
end, { desc = "LSP: Next Diagnostic" })
vim.keymap.set({ "n", "v" }, "[d", function()
  vim.diagnostic.goto_prev({ float = true })
end, { desc = "LSP: Prev Diagnostic" })

vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: Code Action" })

vim.keymap.set({ "n", "v" }, "<leader>cA", function()
  vim.lsp.buf.code_action({
    context = {
      only = {
        "source",
      },
      diagnostics = {},
    },
  })
end, { desc = "LSP: Source Action" })
vim.keymap.set({ "n", "v" }, "<leader>cr", ":IncRename ", { desc = "LSP: Rename" })

-- LSP Navigation (Global Keys)
vim.keymap.set({ "n", "v" }, "gd", function()
  require("snacks").picker.lsp_definitions()
end, { desc = "LSP: Goto Definition" })

vim.keymap.set({ "n", "v" }, "gD", function()
  vim.lsp.buf.definition({
    on_list = function(options)
      if #options.items == 0 then
        vim.notify("No definition found", vim.log.levels.INFO)
        return
      end

      -- Always open in vertical split
      vim.cmd("vsplit")

      -- Jump to the first definition
      local item = options.items[1]
      vim.cmd("edit " .. item.filename)
      vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
    end,
  })
end, { desc = "LSP: Goto Definition (Split)" })

vim.keymap.set({ "n", "v" }, "gI", function()
  require("snacks").picker.lsp_implementations()
end, { desc = "LSP: Goto Implementation" })

vim.keymap.set({ "n", "v" }, "gy", function()
  require("snacks").picker.lsp_type_definitions()
end, { desc = "LSP: Goto Type Definition" })

vim.keymap.set({ "n", "v" }, "gr", function()
  require("snacks").picker.lsp_references()
end, { desc = "LSP: References" })

-- vtsls-specific commands
vim.keymap.set("n", "gS", function()
  local clients = vim.lsp.get_clients({ name = "vtsls" })
  if #clients > 0 then
    local client = clients[1]
    clients[1]:exec_cmd({
      command = "typescript.goToSourceDefinition",
      title = "Go to Source Definition",
      arguments = {
        vim.uri_from_bufnr(0),
        vim.lsp.util.make_position_params(0, client.offset_encoding).position,
      },
    })
  else
    vim.lsp.buf.declaration()
  end
end, { desc = "LSP: Goto Source Definition" })

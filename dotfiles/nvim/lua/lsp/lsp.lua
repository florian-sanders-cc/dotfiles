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

local function lsp_client_complete(arg_lead)
  return vim.tbl_filter(
    function(name)
      return arg_lead == "" or name:find(arg_lead, 1, true) ~= nil
    end,
    vim.tbl_map(function(client)
      return client.name
    end, vim.lsp.get_clients())
  )
end

local function lsp_start_complete(arg_lead)
  local names = {}
  local seen = {}
  for _, c in ipairs(vim.lsp.get_clients()) do
    if not seen[c.name] and (arg_lead == "" or c.name:find(arg_lead, 1, true) ~= nil) then
      names[#names + 1] = c.name
      seen[c.name] = true
    end
  end
  for _, cfg in ipairs(vim.lsp.get_configs({ enabled = true })) do
    if not seen[cfg.name] and (arg_lead == "" or cfg.name:find(arg_lead, 1, true) ~= nil) then
      names[#names + 1] = cfg.name
      seen[cfg.name] = true
    end
  end
  return names
end

-- Stop all or a specific LSP server
vim.api.nvim_create_user_command("LspStop", function(opts)
  local clients = opts.args == "" and vim.lsp.get_clients() or vim.lsp.get_clients({ name = opts.args })
  if #clients == 0 then
    vim.notify(
      opts.args == "" and "No active LSP clients to stop" or "No LSP client found: " .. opts.args,
      vim.log.levels.WARN
    )
    return
  end
  for _, client in ipairs(clients) do
    client:stop()
  end
  vim.notify("Stopped " .. #clients .. " LSP client(s)", vim.log.levels.INFO)
end, {
  nargs = "?",
  complete = lsp_client_complete,
  desc = "Stop all or specified LSP server",
})

-- Restart all or a specific LSP server
vim.api.nvim_create_user_command("LspRestart", function(opts)
  local clients = opts.args == "" and vim.lsp.get_clients() or vim.lsp.get_clients({ name = opts.args })
  if #clients == 0 then
    vim.notify(
      opts.args == "" and "No active LSP clients to restart" or "No LSP client found: " .. opts.args,
      vim.log.levels.WARN
    )
    return
  end
  for _, client in ipairs(clients) do
    local config = vim.deepcopy(client.config)
    if not config or not config.cmd then
      vim.notify("Cannot restart " .. client.name .. ": no config", vim.log.levels.ERROR)
    else
      client:stop()
      vim.defer_fn(function()
        local ok, err = pcall(vim.lsp.start, config)
        if not ok then
          vim.notify("Failed to restart " .. client.name .. ": " .. tostring(err), vim.log.levels.ERROR)
        end
      end, 100)
    end
  end
  vim.notify("Restarting " .. #clients .. " LSP client(s)", vim.log.levels.INFO)
end, {
  nargs = "?",
  complete = lsp_client_complete,
  desc = "Restart all or specified LSP server",
})

-- Start an LSP server by name or for the current buffer
vim.api.nvim_create_user_command("LspStart", function(opts)
  if opts.args == "" then
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    local configs = vim.lsp.get_configs({ enabled = true, filetype = ft })
    local started = 0
    for _, config in ipairs(configs) do
      if #vim.lsp.get_clients({ name = config.name, bufnr = bufnr }) == 0 then
        vim.lsp.start(vim.deepcopy(config), { bufnr = bufnr })
        started = started + 1
      end
    end
    if started == 0 then
      vim.notify("All LSP servers already running for filetype: " .. ft, vim.log.levels.INFO)
    end
  else
    local clients = vim.lsp.get_clients({ name = opts.args })
    if #clients > 0 then
      vim.notify(opts.args .. " is already running", vim.log.levels.INFO)
      return
    end
    local config = vim.lsp.config[opts.args]
    if not config then
      vim.notify("No LSP config found for: " .. opts.args, vim.log.levels.ERROR)
      return
    end
    vim.lsp.start(vim.deepcopy(config))
    vim.notify("Started " .. opts.args, vim.log.levels.INFO)
  end
end, {
  nargs = "?",
  complete = lsp_start_complete,
  desc = "Start specified LSP server or for current buffer",
})

vim.lsp.enable({
  "nil_ls",
  "nixd",
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

-- Delete default Neovim LSP keymaps that conflict with custom `gr` mapping
-- These are set buffer-local on LspAttach, so delete after they're created
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
    pcall(vim.keymap.del, "n", "grr", { buffer = args.buf })
    pcall(vim.keymap.del, "n", "gra", { buffer = args.buf })
    pcall(vim.keymap.del, "n", "grn", { buffer = args.buf })
    pcall(vim.keymap.del, "n", "gri", { buffer = args.buf })
    pcall(vim.keymap.del, "n", "grt", { buffer = args.buf })
  end,
})

vim.diagnostic.config({
  -- float = {
  --   format = function(original_diag)
  --     return string.format("  %s   \n  ", original_diag.message)
  --   end,
  --   header = "",
  --   prefix = function(diagnostic)
  --     return string.format("  \n  %s | %s  \n", diagnostic.source, diagnostic.code), "Comment"
  --   end,
  --   suffix = "",
  -- },
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
  vim.diagnostic.jump({ count = 1, on_jump = vim.diagnostic.open_float })
end, { desc = "LSP: Next Diagnostic" })
vim.keymap.set({ "n", "v" }, "[d", function()
  vim.diagnostic.jump({ count = -1, on_jump = vim.diagnostic.open_float })
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

vim.keymap.set({ "n", "v" }, "<leader>cr", vim.lsp.buf.rename, { desc = "LSP: Rename" })

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
end, { desc = "LSP: References", nowait = true })

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

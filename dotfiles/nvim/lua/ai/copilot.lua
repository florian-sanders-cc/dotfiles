-- Filetypes where Copilot should never attach (security/privacy)
local disabled_filetypes = {
  "dotenv",
  "yaml",
  "markdown",
  "help",
  "gitcommit",
  "gitrebase",
  "hgcommit",
  "svn",
  "cvs",
}

require("copilot").setup({
  -- Prevent LSP from attaching to sensitive files
  -- Signature: should_attach(bufnr, bufname)
  should_attach = function(bufnr, bufname)
    local filename = vim.fs.basename(bufname or "")

    -- Block .env* files by filename pattern
    if filename and string.match(filename, "^%.env") then
      return false
    end

    -- Block by filetype
    local ft = vim.bo[bufnr].filetype
    for _, disabled_ft in ipairs(disabled_filetypes) do
      if ft == disabled_ft then
        return false
      end
    end

    return true
  end,
  suggestion = {
    enabled = true,
    auto_trigger = true, -- Manual trigger only
    hide_during_completion = true,
    debounce = 75,
    keymap = {
      accept = "<C-l>",
      accept_word = false,
      accept_line = false,
      next = "<C-j>", -- Alt+] for next suggestion
      prev = "<C-k>", -- Alt+[ for previous suggestion
      dismiss = "<C-C>", -- Ctrl+] to dismiss
    },
  },
  panel = {
    enabled = true,
    auto_refresh = false,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>", -- Alt+Enter to open panel
    },
    layout = {
      position = "bottom", -- | top | left | right
      ratio = 0.4,
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    dotenv = false,
    ["."] = false,
  },
  copilot_node_command = "node", -- Node.js version must be > 18.x
  server_opts_overrides = {},
})

-- Manual trigger command
vim.keymap.set("i", "<C-g>", function()
  require("copilot.suggestion").toggle_auto_trigger()
end, { desc = "AI: Copilot Toggle Auto Trigger" })

-- Manual suggestion trigger
vim.keymap.set("i", "<M-\\>", function()
  require("copilot.suggestion").next()
end, { desc = "AI: Copilot Request Suggestion" })

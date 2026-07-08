-- =====================================================
-- CLAUDECODE.NVIM
-- =====================================================
--
-- https://github.com/coder/claudecode.nvim
--
-- Unlike a chat plugin, this does NOT talk to an LLM API itself. It starts a
-- local WebSocket server implementing Anthropic's (unpublished) IDE protocol —
-- the same one the VS Code extension speaks — and launches the `claude` CLI in
-- a terminal split with CLAUDE_CODE_SSE_PORT pointing at it. Neovim then acts
-- as the IDE: it streams the current selection/buffer to Claude, and Claude's
-- edits come back as native `vim.diff` splits you accept or reject.
--
-- Consequences of that design:
--   * No API key config here — auth is whatever `claude` already uses.
--   * The `claude` binary must be on PATH (installed via modules/packages).
--   * `snacks.nvim` is picked up automatically as the terminal provider.
--
-- Keymaps live at the bottom of this file, under the <Leader>a "AI" group
-- (declared in ui/which-key.lua). <Leader>ae / as / ao stay reserved for pi
-- (see ai/init.lua), so Claude's send-selection sits on <Leader>aa.

require("claudecode").setup({
  -- Must stay true for the "claude runs in another terminal pane" workflow:
  -- starting the server writes ~/.claude/ide/<port>.lock (ideName "Neovim",
  -- ws transport, authToken, workspaceFolders). That lock file *is* the
  -- discovery mechanism — an external `claude` scans that directory, and
  -- /ide lists this Neovim. No server at startup means no lock file means
  -- nothing to attach to.
  auto_start = true,

  -- nil => run `claude` from PATH. Set to a string to pin flags/binary.
  terminal_cmd = nil,

  log_level = "info",

  -- Keep the "current selection" resource in sync so `@`-mentions and sends
  -- reflect what's actually highlighted.
  track_selection = true,

  -- Stay in the editor after sending; toggle to true if you'd rather land in
  -- the Claude terminal each time.
  focus_after_send = false,

  diff_opts = {
    layout = "vertical",
    open_in_new_tab = false,
    keep_terminal_focus = false,
    -- Rejecting a proposed *new* file leaves the empty placeholder buffer
    -- around rather than yanking the window out from under you.
    on_new_file_reject = "keep_empty",
  },

  terminal = {
    -- "auto" resolves to snacks.nvim here (it's in the plugin list), falling
    -- back to a native terminal split if that ever changes.
    --
    -- This only governs the terminal *this plugin can spawn* via :ClaudeCode.
    -- Attaching a `claude` you started yourself elsewhere works regardless —
    -- it goes through the lock file, not through here. Set this to "none" if
    -- you only ever run Claude externally and want no in-editor terminal at
    -- all (the server and MCP tools stay live either way).
    provider = "auto",
  },
})

-- ┌─────────────────────────┐
-- │ Claude Code             │
-- └─────────────────────────┘

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

-- Session control
map("n", "<Leader>ac", "<cmd>ClaudeCode<CR>", "Claude: toggle")
map("n", "<Leader>af", "<cmd>ClaudeCodeFocus<CR>", "Claude: focus")
map("n", "<Leader>ar", "<cmd>ClaudeCode --resume<CR>", "Claude: resume session")
map("n", "<Leader>aC", "<cmd>ClaudeCode --continue<CR>", "Claude: continue last session")
map("n", "<Leader>am", "<cmd>ClaudeCodeSelectModel<CR>", "Claude: select model")

-- Context
-- Visual mode sends the selection; normal mode sends the current buffer.
map("v", "<Leader>aa", "<cmd>ClaudeCodeSend<CR>", "Claude: send selection")
map("n", "<Leader>ab", "<cmd>ClaudeCodeAdd %<CR>", "Claude: add current buffer")

-- Diff review — these act on the diff Claude is currently proposing.
map("n", "<Leader>ay", "<cmd>ClaudeCodeDiffAccept<CR>", "Claude: accept diff")
map("n", "<Leader>an", "<cmd>ClaudeCodeDiffDeny<CR>", "Claude: deny diff")

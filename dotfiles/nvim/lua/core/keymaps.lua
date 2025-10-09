-- =====================================================
-- ALL NEOVIM KEYMAPS
-- Consolidated keymap configuration for easy management
-- =====================================================

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Terminal mode escape
vim.keymap.set({ "n", "v" }, "<leader>T", "<cmd>term fish<cr>", { desc = "Open terminal in buffer" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Window resizing
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })

-- Better j/k movement with wrap
vim.keymap.set("n", "j", function()
  return tonumber(vim.v.count) > 0 and "j" or "gj"
end, { expr = true, silent = true, desc = "Move down (display lines)" })
vim.keymap.set("n", "k", function()
  return tonumber(vim.v.count) > 0 and "k" or "gk"
end, { expr = true, silent = true, desc = "Move up (display lines)" })

-- Center screen on scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })

-- Clear search highlight
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Save file
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- Window splits
vim.keymap.set("n", "<Leader>_", "<cmd>vsplit<CR>", { silent = true, desc = "Vertical split" })
vim.keymap.set("n", "<Leader>-", "<cmd>split<CR>", { silent = true, desc = "Horizontal split" })

-- Better paste and yank
vim.keymap.set("v", "<Leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set("x", "y", '"+y', { silent = true, desc = "Copy to system clipboard" })

-- Change directory to current file
vim.keymap.set("n", "<leader>cd", function()
  vim.fn.chdir(vim.fn.expand("%:p:h"))
end, { desc = "Change to file directory" })

require("which-key").add({
  -- Main groups
  { "<leader>a", group = "[A]I/Claude Code" },
  { "<leader>a_", hidden = true },
  { "<leader>b", group = "[B]uffer" },
  { "<leader>b_", hidden = true },
  { "<leader>c", group = "[C]ode" },
  { "<leader>c_", hidden = true },
  { "<leader>f", group = "[F]ind" },
  { "<leader>f_", hidden = true },
  { "<leader>g", group = "[G]it" },
  { "<leader>g_", hidden = true },
  { "<leader>m", group = "[M]arkdown" },
  { "<leader>m_", hidden = true },
  { "<leader>o", group = "[O]cto (GitHub)" },
  { "<leader>o_", hidden = true },
  { "<leader>q", group = "[Q]uit/Session" },
  { "<leader>q_", hidden = true },
  { "<leader>s", group = "[S]earch" },
  { "<leader>s_", hidden = true },
  { "<leader>u", group = "[U]I/Toggle" },
  { "<leader>u_", hidden = true },
  { "<leader>x", group = "Diagnostics/Trouble" },
  { "<leader>x_", hidden = true },

  -- Alt/Meta key groups for multicursor operations
  { "<M-", group = "Multi-cursor" },
  { "<M-/", group = "Multi-cursor Search" },

  -- Single key items
  { "<leader>e", desc = "File Explorer" },
  { "<leader>n", desc = "Notification History" },
})

-- =====================================================
-- PLUGIN-SPECIFIC KEYMAPS
-- All keymaps consolidated here for easy management
-- =====================================================

-- =====================================================
-- SNACKS PICKER KEYMAPS
-- =====================================================

-- Top-level quick access
vim.keymap.set({ "n", "v" }, "<leader>ff", function()
  require("snacks").picker.smart()
end, { desc = "Smart Find Files" })

vim.keymap.set({ "n", "v" }, "<leader>,", function()
  require("snacks").picker.buffers()
end, { desc = "Buffers" })

vim.keymap.set({ "n", "v" }, "<leader>/", function()
  require("snacks").picker.grep()
end, { desc = "Grep" })

vim.keymap.set({ "n", "v" }, "<leader>:", function()
  require("snacks").picker.command_history()
end, { desc = "Command History" })

vim.keymap.set({ "n", "v" }, "<leader>n", function()
  require("snacks").picker.notifications()
end, { desc = "Notification History" })

-- File finding (<leader>f)
vim.keymap.set({ "n", "v" }, "<leader>fb", function()
  require("snacks").picker.buffers()
end, { desc = "Buffers" })

vim.keymap.set({ "n", "v" }, "<leader>fc", function()
  require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })

vim.keymap.set({ "n", "v" }, "<leader><space>", function()
  require("snacks").picker.files()
end, { desc = "Find Files" })

vim.keymap.set({ "n", "v" }, "<leader>fg", function()
  require("snacks").picker.git_files()
end, { desc = "Find Git Files" })

vim.keymap.set({ "n", "v" }, "<leader>fp", function()
  require("snacks").picker.projects()
end, { desc = "Projects" })

vim.keymap.set({ "n", "v" }, "<leader>fr", function()
  require("snacks").picker.recent()
end, { desc = "Recent" })

-- Search operations (<leader>s)
vim.keymap.set({ "n", "v" }, "<leader>sb", function()
  require("snacks").picker.lines()
end, { desc = "Buffer Lines" })

vim.keymap.set({ "n", "v" }, "<leader>sB", function()
  require("snacks").picker.grep_buffers()
end, { desc = "Grep Open Buffers" })

vim.keymap.set({ "n", "v" }, "<leader>sg", function()
  require("snacks").picker.grep()
end, { desc = "Grep" })

vim.keymap.set({ "n", "v" }, "<leader>sw", function()
  require("snacks").picker.grep_word()
end, { desc = "Visual selection or word" })

vim.keymap.set({ "n", "v" }, '<leader>s"', function()
  require("snacks").picker.registers()
end, { desc = "Registers" })

vim.keymap.set({ "n", "v" }, "<leader>s/", function()
  require("snacks").picker.search_history()
end, { desc = "Search History" })

vim.keymap.set({ "n", "v" }, "<leader>sa", function()
  require("snacks").picker.autocmds()
end, { desc = "Autocmds" })

vim.keymap.set({ "n", "v" }, "<leader>sc", function()
  require("snacks").picker.command_history()
end, { desc = "Command History" })

vim.keymap.set({ "n", "v" }, "<leader>sC", function()
  require("snacks").picker.commands()
end, { desc = "Commands" })

vim.keymap.set({ "n", "v" }, "<leader>sd", function()
  require("snacks").picker.diagnostics()
end, { desc = "Diagnostics" })

vim.keymap.set({ "n", "v" }, "<leader>sD", function()
  require("snacks").picker.diagnostics_buffer()
end, { desc = "Buffer Diagnostics" })

vim.keymap.set({ "n", "v" }, "<leader>sh", function()
  require("snacks").picker.help()
end, { desc = "Help Pages" })

vim.keymap.set({ "n", "v" }, "<leader>sH", function()
  require("snacks").picker.highlights()
end, { desc = "Highlights" })

vim.keymap.set({ "n", "v" }, "<leader>si", function()
  require("snacks").picker.icons()
end, { desc = "Icons" })

vim.keymap.set({ "n", "v" }, "<leader>sj", function()
  require("snacks").picker.jumps()
end, { desc = "Jumps" })

vim.keymap.set({ "n", "v" }, "<leader>sk", function()
  require("snacks").picker.keymaps()
end, { desc = "Keymaps" })

vim.keymap.set({ "n", "v" }, "<leader>sl", function()
  require("snacks").picker.loclist()
end, { desc = "Location List" })

vim.keymap.set({ "n", "v" }, "<leader>sm", function()
  require("snacks").picker.marks()
end, { desc = "Marks" })

vim.keymap.set({ "n", "v" }, "<leader>sM", function()
  require("snacks").picker.man()
end, { desc = "Man Pages" })

vim.keymap.set({ "n", "v" }, "<leader>sp", function()
  require("snacks").picker.lazy()
end, { desc = "Search for Plugin Spec" })

vim.keymap.set({ "n", "v" }, "<leader>sq", function()
  require("snacks").picker.qflist()
end, { desc = "Quickfix List" })

vim.keymap.set({ "n", "v" }, "<leader>sR", function()
  require("snacks").picker.resume()
end, { desc = "Resume" })

vim.keymap.set({ "n", "v" }, "<leader>ss", function()
  require("snacks").picker.lsp_symbols({
    sort = { "#text" },
  })
end, { desc = "LSP Symbols" })

vim.keymap.set({ "n", "v" }, "<leader>sS", function()
  require("snacks").picker.lsp_workspace_symbols()
end, { desc = "LSP Workspace Symbols" })

vim.keymap.set({ "n", "v" }, "<leader>su", function()
  require("snacks").picker.undo()
end, { desc = "Undo History" })

vim.keymap.set({ "n", "v" }, "<leader>uC", function()
  require("snacks").picker.colorschemes()
end, { desc = "Colorschemes" })

-- LSP Navigation (Global Keys)
vim.keymap.set({ "n", "v" }, "gd", function()
  require("snacks").picker.lsp_definitions()
end, { desc = "Goto Definition" })

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
end, { desc = "Goto Definition (Vertical Split)" })

vim.keymap.set({ "n", "v" }, "gr", function()
  require("snacks").picker.lsp_references()
end, { nowait = true, desc = "References" })

vim.keymap.set({ "n", "v" }, "gI", function()
  require("snacks").picker.lsp_implementations()
end, { desc = "Goto Implementation" })

vim.keymap.set({ "n", "v" }, "gy", function()
  require("snacks").picker.lsp_type_definitions()
end, { desc = "Goto T[y]pe Definition" })

-- =====================================================
-- SNACKS BUFFER KEYMAPS
-- =====================================================

-- Buffer management (<leader>b)
vim.keymap.set("n", "<leader>bd", function()
  require("snacks").bufdelete()
end, { desc = "Delete current buffer" })

vim.keymap.set("n", "<leader>ba", function()
  require("snacks").bufdelete.all()
end, { desc = "Delete all buffers" })

vim.keymap.set("n", "<leader>bo", function()
  require("snacks").bufdelete.other()
end, { desc = "Delete other buffers" })

-- =====================================================
-- SNACKS EXPLORER KEYMAPS
-- =====================================================

-- File Explorer
vim.keymap.set({ "n", "v" }, "<leader>e", function()
  require("snacks").explorer()
end, { desc = "File Explorer" })

-- Flash (search and movement)
vim.keymap.set({ "n", "x", "o" }, "gs", function()
  require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "gt", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })

-- Multi-cursor keymaps
-- Pressing `gaip` will add a cursor on each line of a paragraph.
vim.keymap.set("n", "<M-%>", require("multicursor-nvim").addCursorOperator, { desc = "Add cursor with text object" })

vim.keymap.set({ "n", "v" }, "<M-q>", function()
  if not require("multicursor-nvim").cursorsEnabled() then
    require("multicursor-nvim").enableCursors()
  else
    require("multicursor-nvim").clearCursors()
  end
end, { desc = "Remove multicursors" })

-- Align cursor columns.
vim.keymap.set("n", "<M-A>", require("multicursor-nvim").alignCursors, { desc = "Align cursor columns" })

-- bring back cursors if you accidentally clear them
vim.keymap.set("n", "<M-u>", require("multicursor-nvim").restoreCursors, { desc = "Restore cleared cursors" })

-- Add a cursor for all matches of cursor word/selection in the document.
vim.keymap.set(
  { "n", "x" },
  "<M-a>",
  require("multicursor-nvim").matchAllAddCursors,
  { desc = "Add cursor for all word matches" }
)

-- Rotate the text contained in each visual selection between cursors.
vim.keymap.set("x", "<M-t>", function()
  require("multicursor-nvim").transposeCursors(1)
end, { desc = "Rotate cursor text forward" })
vim.keymap.set("x", "<M-T>", function()
  require("multicursor-nvim").transposeCursors(-1)
end, { desc = "Rotate cursor text backward" })

-- Append/insert for each line of visual selections.
-- Similar to block selection insertion.
vim.keymap.set("x", "I", require("multicursor-nvim").insertVisual, { desc = "Insert at cursor start" })
vim.keymap.set("x", "A", require("multicursor-nvim").appendVisual, { desc = "Append at cursor end" })

-- Increment/decrement sequences, treaing all cursors as one sequence.
vim.keymap.set(
  { "n", "x" },
  "<M-ca>",
  require("multicursor-nvim").sequenceIncrement,
  { desc = "Increment cursor sequence" }
)
vim.keymap.set(
  { "n", "x" },
  "<M-cx>",
  require("multicursor-nvim").sequenceDecrement,
  { desc = "Decrement cursor sequence" }
)

vim.keymap.set({ "n", "x" }, "<M-k>", function()
  require("multicursor-nvim").lineAddCursor(-1)
end, { desc = "Add cursor to line above" })
vim.keymap.set({ "n", "x" }, "<M-j>", function()
  require("multicursor-nvim").lineAddCursor(1)
end, { desc = "Add cursor to line below" })
vim.keymap.set({ "n", "x" }, "<M-up>", function()
  require("multicursor-nvim").lineSkipCursor(-1)
end, { desc = "Skip cursor to line above" })
vim.keymap.set({ "n", "x" }, "<M-down>", function()
  require("multicursor-nvim").lineSkipCursor(1)
end, { desc = "Skip cursor to line below" })

-- Add or skip adding a new cursor by matching word/selection
vim.keymap.set({ "n", "x" }, "<M-n>", function()
  require("multicursor-nvim").matchAddCursor(1)
end, { desc = "Add cursor at next word match" })
-- vim.keymap.set({ "x" }, "<M-,>", function()
--   require("multicursor-nvim").matchAddCursor(1)
-- end, { desc = "Add cursor at next word match" })
vim.keymap.set({ "n", "x" }, "<M-s>", function()
  require("multicursor-nvim").matchSkipCursor(1)
end, { desc = "Skip cursor at next word match" })
vim.keymap.set({ "n", "x" }, "<M-N>", function()
  require("multicursor-nvim").matchAddCursor(-1)
end, { desc = "Add cursor at previous word match" })
vim.keymap.set({ "n", "x" }, "<M-S>", function()
  require("multicursor-nvim").matchSkipCursor(-1)
end, { desc = "Skip cursor at previous word match" })

-- Add or skip adding a new cursor by matching diagnostics.
vim.keymap.set({ "n", "x" }, "<M-]d>", function()
  require("multicursor-nvim").diagnosticAddCursor(1)
end, { desc = "Add cursor at next diagnostic" })
vim.keymap.set({ "n", "x" }, "<M-[d>", function()
  require("multicursor-nvim").diagnosticAddCursor(-1)
end, { desc = "Add cursor at previous diagnostic" })
vim.keymap.set({ "n", "x" }, "<M-]s>", function()
  require("multicursor-nvim").diagnosticSkipCursor(1)
end, { desc = "Skip cursor at next diagnostic" })
vim.keymap.set({ "n", "x" }, "<M-[S>", function()
  require("multicursor-nvim").diagnosticSkipCursor(-1)
end, { desc = "Skip cursor at previous diagnostic" })

-- Press `mdip` to add a cursor for every error diagnostic in the range `ip`.
vim.keymap.set({ "n", "x" }, "<M-md>", function()
  -- See `:h vim.diagnostic.GetOpts`.
  require("multicursor-nvim").diagnosticMatchCursors({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Add cursors to all error diagnostics" })

-- Search and Replace
vim.keymap.set({ "n", "v" }, "<leadersr", function()
  local grug = require("grug-far")
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= "" and "*." .. ext or nil,
    },
  })
end, { desc = "Search and Replace" })

-- Disable 's' key for flash usage
vim.keymap.set({ "n", "v" }, "s", "<Nop>")

-- =====================================================
-- LSP KEYMAPS
-- =====================================================

-- LSP Code Actions
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set({ "n", "v" }, "<leader>cA", function()
  vim.lsp.buf.code_action({
    context = {
      only = {
        "source",
      },
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
      title = "Go to Source Definition",
      arguments = {
        vim.uri_from_bufnr(0),
        vim.lsp.util.make_position_params(0, client.offset_encoding).position,
      },
    })
  else
    vim.lsp.buf.declaration()
  end
end, { desc = "Go to Source Definition" })

-- =====================================================
-- SESSION KEYMAPS
-- =====================================================

-- Session management
vim.keymap.set("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Load session for current directory" })

vim.keymap.set("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Select session to load" })

vim.keymap.set("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Load last session" })

vim.keymap.set("n", "<leader>qq", require("lib.session-quit").quit_with_session_save, {
  desc = "Save session and quit",
})

-- =====================================================
-- OCTO/GITHUB KEYMAPS
-- =====================================================

vim.keymap.set({ "n", "v" }, "<leader>o", "<cmd>Octo<cr>", { desc = "Octo GitHub" })

-- GitHub/Octo operations - all start with "o" for easy recall
-- vim.keymap.set({ "n" }, "<leader>oo", function()
--   vim.ui.input({ prompt = "Issue/PR URL or number: " }, function(input)
--     if input and input ~= "" then
--       vim.cmd("Octo " .. input)
--     end
--   end)
-- end, { desc = "Open Issue/PR" })
-- vim.keymap.set({ "n", "v" }, "<leader>oa", "<cmd>Octo actions<cr>", { desc = "Actions" })
--
-- -- Issues (o + i + action)
-- vim.keymap.set({ "n" }, "<leader>oil", "<cmd>Octo issue list<cr>", { desc = "Issue List" })
-- vim.keymap.set({ "n" }, "<leader>ois", "<cmd>Octo issue search<cr>", { desc = "Issue Search" })
-- vim.keymap.set({ "n" }, "<leader>oic", "<cmd>Octo issue create<cr>", { desc = "Issue Create" })
-- vim.keymap.set({ "n" }, "<leader>oie", "<cmd>Octo issue edit<cr>", { desc = "Issue Edit" })
-- vim.keymap.set({ "n" }, "<leader>oir", "<cmd>Octo issue reload<cr>", { desc = "Issue Reload" })
-- vim.keymap.set({ "n" }, "<leader>oib", "<cmd>Octo issue browser<cr>", { desc = "Issue Browser" })
-- vim.keymap.set({ "n" }, "<leader>oiu", "<cmd>Octo issue url<cr>", { desc = "Issue URL" })
-- vim.keymap.set({ "n" }, "<leader>oix", "<cmd>Octo issue close<cr>", { desc = "Issue Close" })
-- vim.keymap.set({ "n" }, "<leader>oio", "<cmd>Octo issue reopen<cr>", { desc = "Issue Open" })
--
-- -- Pull Requests (o + p + action)
-- vim.keymap.set({ "n" }, "<leader>opl", "<cmd>Octo pr list<cr>", { desc = "PR List" })
-- vim.keymap.set({ "n" }, "<leader>ops", "<cmd>Octo pr search<cr>", { desc = "PR Search" })
-- vim.keymap.set({ "n" }, "<leader>opc", "<cmd>Octo pr create<cr>", { desc = "PR Create" })
-- vim.keymap.set({ "n" }, "<leader>ope", "<cmd>Octo pr edit<cr>", { desc = "PR Edit" })
-- vim.keymap.set({ "n" }, "<leader>opk", "<cmd>Octo pr checkout<cr>", { desc = "PR Checkout" })
-- vim.keymap.set({ "n" }, "<leader>opm", "<cmd>Octo pr merge<cr>", { desc = "PR Merge" })
-- vim.keymap.set({ "n" }, "<leader>opd", "<cmd>Octo pr diff<cr>", { desc = "PR Diff" })
-- vim.keymap.set({ "n" }, "<leader>opt", "<cmd>Octo pr commits<cr>", { desc = "PR Commits" })
-- vim.keymap.set({ "n" }, "<leader>opg", "<cmd>Octo pr changes<cr>", { desc = "PR Changes" })
-- vim.keymap.set({ "n" }, "<leader>opj", "<cmd>Octo pr checks<cr>", { desc = "PR Checks" })
-- vim.keymap.set({ "n" }, "<leader>opb", "<cmd>Octo pr browser<cr>", { desc = "PR Browser" })
-- vim.keymap.set({ "n" }, "<leader>opx", "<cmd>Octo pr close<cr>", { desc = "PR Close" })
-- vim.keymap.set({ "n" }, "<leader>opo", "<cmd>Octo pr reopen<cr>", { desc = "PR Open" })
--
-- -- Repository (o + r + action)
-- vim.keymap.set({ "n" }, "<leader>orl", "<cmd>Octo repo list<cr>", { desc = "Repo List" })
-- vim.keymap.set({ "n" }, "<leader>orf", "<cmd>Octo repo fork<cr>", { desc = "Repo Fork" })
-- vim.keymap.set({ "n" }, "<leader>orb", "<cmd>Octo repo browser<cr>", { desc = "Repo Browser" })
-- vim.keymap.set({ "n" }, "<leader>oru", "<cmd>Octo repo url<cr>", { desc = "Repo URL" })
--
-- -- Comments (o + c + action)
-- vim.keymap.set({ "n" }, "<leader>oca", "<cmd>Octo comment add<cr>", { desc = "Comment Add" })
-- vim.keymap.set({ "n" }, "<leader>ocd", "<cmd>Octo comment delete<cr>", { desc = "Comment Delete" })
--
-- -- Reviews (o + v + action)
-- vim.keymap.set({ "n" }, "<leader>ovs", "<cmd>Octo review start<cr>", { desc = "Review Start" })
-- vim.keymap.set({ "n" }, "<leader>ovr", "<cmd>Octo review resume<cr>", { desc = "Review Resume" })
-- vim.keymap.set({ "n" }, "<leader>ovd", "<cmd>Octo review discard<cr>", { desc = "Review Discard" })
-- vim.keymap.set({ "n" }, "<leader>ovb", "<cmd>Octo review submit<cr>", { desc = "Review Submit" })
-- vim.keymap.set({ "n" }, "<leader>ovc", "<cmd>Octo review comments<cr>", { desc = "Review Comments" })
-- vim.keymap.set({ "n" }, "<leader>ovc", "<cmd>Octo review <cr>", { desc = "Review Comments" })
--
-- -- Reactions (o + e + reaction)
-- vim.keymap.set({ "n" }, "<leader>oe+", "<cmd>Octo reaction +1<cr>", { desc = "👍 Reaction" })
-- vim.keymap.set({ "n" }, "<leader>oe-", "<cmd>Octo reaction -1<cr>", { desc = "👎 Reaction" })
-- vim.keymap.set({ "n" }, "<leader>oeh", "<cmd>Octo reaction heart<cr>", { desc = "❤️ Reaction" })
-- vim.keymap.set({ "n" }, "<leader>oel", "<cmd>Octo reaction laugh<cr>", { desc = "😄 Reaction" })
-- vim.keymap.set({ "n" }, "<leader>oef", "<cmd>Octo reaction confused<cr>", { desc = "😕 Reaction" })
-- vim.keymap.set({ "n" }, "<leader>oer", "<cmd>Octo reaction rocket<cr>", { desc = "🚀 Reaction" })
-- vim.keymap.set({ "n" }, "<leader>oey", "<cmd>Octo reaction eyes<cr>", { desc = "👀 Reaction" })
--
-- -- Labels (o + l + action)
-- vim.keymap.set({ "n" }, "<leader>ola", "<cmd>Octo label add<cr>", { desc = "Label Add" })
-- vim.keymap.set({ "n" }, "<leader>olr", "<cmd>Octo label remove<cr>", { desc = "Label Remove" })
-- vim.keymap.set({ "n" }, "<leader>olc", "<cmd>Octo label create<cr>", { desc = "Label Create" })
--
-- -- Assignees (o + a + action)
-- vim.keymap.set({ "n" }, "<leader>oaa", "<cmd>Octo assignee add<cr>", { desc = "Assignee Add" })
-- vim.keymap.set({ "n" }, "<leader>oar", "<cmd>Octo assignee remove<cr>", { desc = "Assignee Remove" })
--
-- -- Search (o + s + type)
-- vim.keymap.set({ "n" }, "<leader>oss", "<cmd>Octo search<cr>", { desc = "Search" })
--
-- -- Threads/Discussions (o + t + action)
-- vim.keymap.set({ "n" }, "<leader>otr", "<cmd>Octo thread resolve<cr>", { desc = "Thread Resolve" })
-- vim.keymap.set({ "n" }, "<leader>otu", "<cmd>Octo thread unresolve<cr>", { desc = "Thread Unresolve" })

-- =====================================================
-- AI/CLAUDE CODE KEYMAPS
-- =====================================================

-- Claude Code AI integration
-- vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
-- vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
-- vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
-- vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
-- vim.keymap.set("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Claude model" })
-- vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
-- vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
-- vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
-- vim.keymap.set({ "n", "v" }, "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })

-- Codecompanion AI integration
vim.keymap.set(
  { "n", "v" },
  "<leader>ai",
  ":CodeCompanion ",
  { desc = "CodeCompanion: Inline Assistant", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "v" },
  "<leader>ac",
  "<cmd>CodeCompanionChat<CR>",
  { desc = "CodeCompanion: Chat Buffer", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "v" },
  "<leader>am",
  "<cmd>CodeCompanionCmd<CR>",
  { desc = "CodeCompanion: Command Generator", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "v" },
  "<leader>aA",
  "<cmd>CodeCompanionActions<CR>",
  { desc = "CodeCompanion: Action Palette", noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "v" },
  "<leader>ag",
  ":CodeCompanion <CR>",
  { desc = "CodeCompanion: Resume Session", noremap = true, silent = true }
)

-- =====================================================
-- UI/FILES KEYMAPS
-- =====================================================

-- Mini.files integration
vim.keymap.set({ "n" }, "<leader>fM", function()
  require("mini.files").open(vim.uv.cwd(), true)
end, { desc = "Open mini.files (cwd)" })

-- Todo Comments
vim.keymap.set("n", "<leader>xt", function()
  require("snacks").picker.todo_comments({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Todo Comments (Buffer)" })

vim.keymap.set("n", "<leader>xT", function()
  require("snacks").picker.todo_comments()
end, { desc = "Todo Comments (Workspace)" })

-- Notifications
vim.keymap.set({ "n", "v" }, "<leader>sn", function()
  require("snacks").notifier.show_history()
end, { desc = "Show notification history" })

vim.keymap.set({ "n", "v" }, "<leader>un", function()
  require("snacks").notifier.hide()
end, { desc = "Hide notifications" })

-- Markdown
vim.keymap.set({ "n" }, "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown Preview toggle" })

local Snacks = require("snacks")

Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle
  .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
  :map("<leader>uc")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.zen():map("<leader>uz")
Snacks.toggle.dim():map("<leader>uD")

-- Custom formatting toggle
Snacks.toggle({
  name = "Auto Formatting",
  get = function()
    return not vim.g.disable_autoformat and not vim.b.disable_autoformat
  end,
  set = function(state)
    if state then
      vim.g.disable_autoformat = false
      vim.b.disable_autoformat = false
    else
      vim.g.disable_autoformat = true
    end
  end,
}):map("<leader>uf")

-- =====================================================
-- GIT KEYMAPS
-- =====================================================

-- Git operations
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Open Neogit" })
vim.keymap.set("n", "<leader>gc", "<cmd>Neogit commit<cr>", { desc = "Neogit Commit" })

-- Diffview
vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "Open File History" })
vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "Open Current File History" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
vim.keymap.set("n", "<leader>ge", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle Diffview Files" })

-- ┌─────────────────┐
-- │ jj.nvim         │
-- └─────────────────┘
--
-- Drive Jujutsu (jj) VCS from Neovim.

require("jj").setup({
  picker = {
    snacks = {},
  },
  terminal = {
    cursor_render_delay = 10,
  },
  diff = {
    -- Use native backend: diff editing is handled externally by hunk.nvim
    -- via jj's ui.diff-editor config, not by this plugin's backend.
    backend = "native",
  },
  cmd = {
    describe = {
      editor = {
        type = "buffer",
        keymaps = {
          close = { "<C-c>", "q" },
        },
      },
    },
    log = {
      close_on_edit = false,
    },
    keymaps = {
      log = {
        checkout = "<CR>",
        checkout_immutable = "<S-CR>",
        describe = "d",
        diff = "<S-d>",
        edit = "e",
        new = "n",
        new_after = "<C-n>",
        new_after_immutable = "<S-n>",
        undo = "<S-u>",
        redo = "<S-r>",
        abandon = "a",
        bookmark = "b",
        fetch = "f",
        push = "p",
        push_all = "<S-p>",
        open_pr = "o",
        open_pr_list = "<S-o>",
        rebase = "r",
        squash = "s",
        quick_squash = "<S-s>",
        split = "<C-s>",
        tag_create = "<S-t>",
        summary = "<S-k>",
      },
      status = {
        open_file = "<CR>",
        restore_file = "<S-x>",
      },
      close = { "q", "<Esc>" },
    },
  },
})

-- ┌──────────────────────────────────────────┐
-- │ Keymaps                                  │
-- └──────────────────────────────────────────┘

local cmd = require("jj.cmd")
local diff = require("jj.diff")
local picker = require("jj.picker")

-- Core commands
vim.keymap.set("n", "<leader>jl", cmd.log, { desc = "Jujutsu: Log" })
vim.keymap.set("n", "<leader>js", cmd.status, { desc = "Jujutsu: Status" })
vim.keymap.set("n", "<leader>jd", cmd.describe, { desc = "Jujutsu: Describe" })
vim.keymap.set("n", "<leader>jn", cmd.new, { desc = "Jujutsu: New" })
vim.keymap.set("n", "<leader>je", cmd.edit, { desc = "Jujutsu: Edit" })
vim.keymap.set("n", "<leader>ju", cmd.undo, { desc = "Jujutsu: Undo" })
vim.keymap.set("n", "<leader>jy", cmd.redo, { desc = "Jujutsu: Redo" })
vim.keymap.set("n", "<leader>jp", cmd.push, { desc = "Jujutsu: Push" })
vim.keymap.set("n", "<leader>jf", cmd.fetch, { desc = "Jujutsu: Fetch" })
vim.keymap.set("n", "<leader>jr", cmd.rebase, { desc = "Jujutsu: Rebase" })
vim.keymap.set("n", "<leader>j-", cmd.abandon, { desc = "Jujutsu: Abandon" })

-- Diff commands
vim.keymap.set("n", "<leader>jD", function() diff.diff_current({ layout = "vertical" }) end, { desc = "Jujutsu: Diff (vertical)" })
vim.keymap.set("n", "<leader>jH", function() diff.diff_current({ layout = "horizontal" }) end, { desc = "Jujutsu: Diff (horizontal)" })

-- Pickers
vim.keymap.set("n", "<leader>jgs", function() picker.status() end, { desc = "Jujutsu: Picker Status" })
vim.keymap.set("n", "<leader>jgh", function() picker.file_history() end, { desc = "Jujutsu: Picker File History" })

-- Register which-key subgroup for pickers
WhichKey.add({
  { "<leader>jg", group = "Jujutsu: Pickers" },
})

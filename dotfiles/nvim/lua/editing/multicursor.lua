local mc = require("multicursor-nvim")
mc.setup()

-- Mappings defined in a keymap layer only apply when there are
-- multiple cursors. This lets you have overlapping mappings.
mc.addKeymapLayer(function(layerSet)
  -- Select a different cursor as the main one.
  layerSet({ "n", "x" }, "<left>", mc.prevCursor)
  layerSet({ "n", "x" }, "<right>", mc.nextCursor)

  -- Delete the main cursor.
  layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

  -- Enable and clear cursors using escape.
  layerSet("n", "<esc>", function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)

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

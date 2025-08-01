return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	config = function()
		local mc = require("multicursor-nvim")

		mc.setup()

		local set = vim.keymap.set

		-- Add cursors above/below the main cursor
		set({ "n", "v" }, "<M-k>", function()
			mc.lineAddCursor(-1)
		end, { desc = "Add cursor above" })
		set({ "n", "v" }, "<M-j>", function()
			mc.lineAddCursor(1)
		end, { desc = "Add cursor below" })

		-- Add cursor to each word that matches the word under the cursor
		set({ "n", "v" }, "<M-n>", function()
			mc.matchAddCursor(1)
		end, { desc = "Add cursor to next match" })
		set({ "n", "v" }, "<M-s>", function()
			mc.matchAddCursor(-1)
		end, { desc = "Add cursor to prev match" })

		-- Add a cursor for all matches of cursor word/selection in the document.
		set({ "n", "x" }, "<M-a>", mc.matchAllAddCursors)

		-- Rotate the main cursor
		set({ "n", "v" }, "<left>", mc.nextCursor, { desc = "Next cursor" })
		set({ "n", "v" }, "<right>", mc.prevCursor, { desc = "Previous cursor" })

		-- Delete the main cursor
		set({ "n", "v" }, "<leader>x", mc.deleteCursor, { desc = "Delete cursor" })

		-- Add and remove cursors with control + left click
		set("n", "<M-leftmouse>", mc.handleMouse, { desc = "Add/remove cursor" })

		-- Easy way to add and remove cursors using the main cursor
		set({ "n", "v" }, "<c-q>", function()
			if mc.cursorsEnabled() then
				mc.disableCursors()
			else
				mc.addCursor()
			end
		end, { desc = "Toggle cursor" })

		-- clone every cursor and disable the originals
		set({ "n", "v" }, "<leader><c-q>", mc.duplicateCursors, { desc = "Duplicate cursors" })

		set("n", "<esc>", function()
			if not mc.cursorsEnabled() then
				mc.enableCursors()
			elseif mc.hasCursors() then
				mc.clearCursors()
			else
				-- Default <esc> handler
			end
		end, { desc = "Clear cursors" })

		-- Align cursor columns
		set("v", "<M-l>", mc.alignCursors, { desc = "Align cursors" })

		-- Split visual selections by regex
		set("v", "S", mc.splitCursors, { desc = "Split cursors" })

		-- Append/insert for each line of visual selections
		set("v", "I", mc.insertVisual, { desc = "Insert at start" })
		set("v", "A", mc.appendVisual, { desc = "Append at end" })

		-- match new cursors within visual selections by regex
		set("v", "M", mc.matchCursors, { desc = "Match cursors" })

		-- Rotate visual selection contents
		set("v", "<leader>t", function()
			mc.transposeCursors(1)
		end, { desc = "Transpose cursors" })
		set("v", "<leader>T", function()
			mc.transposeCursors(-1)
		end, { desc = "Transpose cursors backwards" })

		-- Customize how cursors look
		local hl = vim.api.nvim_set_hl
		hl(0, "MultiCursorCursor", { link = "Cursor" })
		hl(0, "MultiCursorVisual", { link = "Visual" })
		hl(0, "MultiCursorSign", { link = "SignColumn" })
		hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
		hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
		hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
	end,
}

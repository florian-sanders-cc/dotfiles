-- =====================================================
-- SNACKS EXPLORER Configuration
-- =====================================================

local M = {}

M.config = {
  explorer = {
    enabled = true,
    replace_netrw = true,
  }
}

M.keymaps = {
  -- File Explorer
  {
    { "n",                   "v" },
    "<leader>e",
    function() require("snacks").explorer() end,
    { desc = "File Explorer" }
  },
}

return M

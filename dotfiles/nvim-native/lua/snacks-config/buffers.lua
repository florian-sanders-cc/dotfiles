-- =====================================================
-- SNACKS BUFFER MANAGEMENT Configuration
-- =====================================================

local M = {}

M.config = {
  -- Buffer delete functionality is built-in
  bufdelete = {
    enabled = true
  }
}

M.keymaps = {
  -- Buffer management (<leader>b)
  {
    "n",
    "<leader>bd",
    function() require("snacks").bufdelete() end,
    { desc = "Delete current buffer" }
  },
  {
    "n",
    "<leader>ba",
    function() require("snacks").bufdelete.all() end,
    { desc = "Delete all buffers" }
  },
  {
    "n",
    "<leader>bo",
    function() require("snacks").bufdelete.other() end,
    { desc = "Delete other buffers" }
  },
}

return M

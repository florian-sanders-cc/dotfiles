require("litee.lib").setup()
require("litee.gh").setup({
  -- deprecated, around for compatability for now.
  jump_mode = "invoking",
  -- remap the arrow keys to resize any litee.nvim windows.
  map_resize_keys = false,
  -- do not map any keys inside any gh.nvim buffers.
  disable_keymaps = false,
  -- the icon set to use.
  icon_set = "default",
  -- any custom icons to use.
  icon_set_custom = nil,
  -- whether to register the @username and #issue_number omnifunc completion
  -- in buffers which start with .git/
  git_buffer_completion = true,
  -- defines keymaps in gh.nvim buffers.
  keymaps = {
    -- when inside a gh.nvim panel, this key will open a node if it has
    -- any futher functionality. for example, hitting <CR> on a commit node
    -- will open the commit's changed files in a new gh.nvim panel.
    open = "<CR>",
    -- when inside a gh.nvim panel, expand a collapsed node
    expand = "zo",
    -- when inside a gh.nvim panel, collpased and expanded node
    collapse = "zc",
    -- when cursor is over a "#1234" formatted issue or PR, open its details
    -- and comments in a new tab.
    goto_issue = "gd",
    -- show any details about a node, typically, this reveals commit messages
    -- and submitted review bodys.
    details = "d",
    -- inside a convo buffer, submit a comment
    submit_comment = "<C-s>",
    -- inside a convo buffer, when your cursor is ontop of a comment, open
    -- up a set of actions that can be performed.
    actions = "<C-a>",
    -- inside a thread convo buffer, resolve the thread.
    resolve_thread = "<C-r>",
    -- inside a gh.nvim panel, if possible, open the node's web URL in your
    -- browser. useful particularily for digging into external failed CI
    -- checks.
    goto_web = "gx",
  },
})

local wk = require("which-key")
wk.add({
  { "<leader>Gc", group = "Commits" },
  { "<leader>Gcc", "<cmd>GHCloseCommit<cr>", desc = "Close" },
  { "<leader>Gce", "<cmd>GHExpandCommit<cr>", desc = "Expand" },
  { "<leader>Gco", "<cmd>GHOpenToCommit<cr>", desc = "Open To" },
  { "<leader>Gcp", "<cmd>GHPopOutCommit<cr>", desc = "Pop Out" },
  { "<leader>Gcz", "<cmd>GHCollapseCommit<cr>", desc = "Collapse" },
  { "<leader>Gi", group = "Issues" },
  { "<leader>Gip", "<cmd>GHPreviewIssue<cr>", desc = "Preview" },
  { "<leader>Gl", group = "Litee" },
  { "<leader>Glt", "<cmd>LTPanel<cr>", desc = "Toggle Panel" },
  { "<leader>Gp", group = "Pull Request" },
  { "<leader>Gpc", "<cmd>GHClosePR<cr>", desc = "Close" },
  { "<leader>Gpd", "<cmd>GHPRDetails<cr>", desc = "Details" },
  { "<leader>Gpe", "<cmd>GHExpandPR<cr>", desc = "Expand" },
  { "<leader>Gpo", "<cmd>GHOpenPR<cr>", desc = "Open" },
  { "<leader>Gpp", "<cmd>GHPopOutPR<cr>", desc = "PopOut" },
  { "<leader>Gpr", "<cmd>GHRefreshPR<cr>", desc = "Refresh" },
  { "<leader>Gpt", "<cmd>GHOpenToPR<cr>", desc = "Open To" },
  { "<leader>Gpz", "<cmd>GHCollapsePR<cr>", desc = "Collapse" },
  { "<leader>Gr", group = "Review" },
  { "<leader>Grb", "<cmd>GHStartReview<cr>", desc = "Begin" },
  { "<leader>Grc", "<cmd>GHCloseReview<cr>", desc = "Close" },
  { "<leader>Grd", "<cmd>GHDeleteReview<cr>", desc = "Delete" },
  { "<leader>Gre", "<cmd>GHExpandReview<cr>", desc = "Expand" },
  { "<leader>Grs", "<cmd>GHSubmitReview<cr>", desc = "Submit" },
  { "<leader>Grz", "<cmd>GHCollapseReview<cr>", desc = "Collapse" },
  { "<leader>Gt", group = "Threads" },
  { "<leader>Gtc", "<cmd>GHCreateThread<cr>", desc = "Create" },
  { "<leader>Gtn", "<cmd>GHNextThread<cr>", desc = "Next" },
  { "<leader>Gtt", "<cmd>GHToggleThread<cr>", desc = "Toggle" },
})

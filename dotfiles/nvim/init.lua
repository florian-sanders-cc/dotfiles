-- Plugin orchestration (loads snacks with distributed configs)
require("core.plugin-orchestration")

-- Core configuration
require("core.options")
require("core.startup-timer")
require("core.sessions")
require("core.keymaps")
require("core.alacritty")

-- Editing features
require("editing.misc")
require("editing.completion")
require("editing.text-manipulation")
require("editing.formatting")
require("editing.treesitter")

-- UI components
require("ui.statusline")
require("ui.misc") -- Load custom hover handler

-- Git integration
require("git.integration")
require("git.reviews")

-- LSP configuration
require("lsp.lsp")

-- AI integration
require("ai.claude")
require("ai.codecompanion")
-- require("ai.sidekick")

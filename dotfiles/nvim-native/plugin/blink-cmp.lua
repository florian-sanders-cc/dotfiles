-- =====================================================
-- BLINK.CMP COMPLETION CONFIGURATION
-- Modern completion engine with Rust fuzzy matching
-- =====================================================

require("blink.cmp").setup({
  -- Keymap preset - 'enter' for enter to accept, similar to VSCode
  keymap = { preset = 'enter' },

  -- Appearance configuration
  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
  },

  -- Completion window styling
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
      window = {
        border = 'none',
        max_width = 80,
        max_height = 20,
        winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None',
      },
    },
    menu = {
      border = 'none',
      max_height = 10,
      winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
    },
  },

  -- Function signature help
  signature = {
    enabled = true,
    window = {
      border = 'none',
      max_width = 80,
      max_height = 10,
      winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
      show_documentation = false,
    },
  },

  -- Completion sources
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },

  -- Rust fuzzy matcher for performance and typo resistance
  fuzzy = { 
    implementation = 'prefer_rust_with_warning' 
  },
})
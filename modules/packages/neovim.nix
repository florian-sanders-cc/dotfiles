{ lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    defaultEditor = true;
    # package = pkgs.neovim-nightly-pkgs;

    extraPackages = with pkgs; [
      # Core
      gcc
      libgcc
      stylua

      # LSP
      lua-language-server
      nixd
      nodePackages_latest.prettier
      typescript
      vscode-langservers-extracted

      # Tools
      fd
      lazygit
      ripgrep
    ];

    plugins = with pkgs.vimPlugins; [ lazy-nvim ];

    extraLuaConfig =
      let
        plugins = with pkgs.vimPlugins; [
          # Core
          LazyVim
          lazy-nvim
          nui-nvim
          plenary-nvim

          # LSP & Completion
          SchemaStore-nvim
          aerial-nvim
          conform-nvim
          friendly-snippets
          mason-lspconfig-nvim
          mason-nvim
          neogen
          nvim-lint
          nvim-lspconfig
          rustaceanvim # Not available in nixpkgs

          # Editor Features
          mini-nvim # For mini.pairs, mini.surround, mini.ai, mini.files, mini.hipatterns
          # multiple-cursors-nvim # Not available in nixpkgs
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-ts-autotag
          persistence-nvim
          ts-comments-nvim # Not available in nixpkgs
          yanky-nvim

          # Navigation & Search
          # ctrlsf-vim
          fzf-lua # Not available in nixpkgs
          neo-tree-nvim
          telescope-nvim
          trouble-nvim

          # Git Integration
          diffview-nvim
          gitsigns-nvim
          neogit

          # UI Components
          dressing-nvim
          lualine-nvim
          noice-nvim
          nvim-notify
          nvim-web-devicons
          which-key-nvim

          # Themes
          catppuccin-nvim
          kanagawa-nvim
          nordic-nvim # Not available in nixpkgs
          tokyonight-nvim

          # Special Features
          avante-nvim # Not available in nixpkgs
          blink-cmp # Not available in nixpkgs
          copilot-lua
          img-clip-nvim # Not available in nixpkgs
          lazydev-nvim # Not available in nixpkgs
          render-markdown-nvim # Not available in nixpkgs
          snacks-nvim # Not available in nixpkgs
        ];
        mkEntryFromDrv =
          drv:
          if lib.isDerivation drv then
            {
              name = "${lib.getName drv}";
              path = drv;
            }
          else
            drv;
        lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
      in
      ''
        require("lazy").setup({
          defaults = {
            lazy = true,
          },
          performance = {
            reset_packpath = false,
            rtp = {
                reset = false,
            }
          },
          dev = {
            -- reuse files from pkgs.vimPlugins.*
            path = "${lazyPath}",
            patterns = { ".", "file-history" },
            -- fallback to download
            fallback = false,
          },
          install = {
            -- Safeguard in case we forget to install a plugin with Nix
            missing = false,
          },
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            -- The following configs are needed for fixing lazyvim on nix
            -- force enable telescope-fzf-native.nvim
            { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
            -- disable mason.nvim, use programs.neovim.extraPackages
            { "williamboman/mason-lspconfig.nvim", enabled = false },
            { "williamboman/mason.nvim", enabled = false },
            -- import/override with your plugins
            { import = "plugins" },
            { import = "lazyvim.plugins.extras.coding.mini-surround" },
            { import = "lazyvim.plugins.extras.editor.inc-rename" },
            { import = "lazyvim.plugins.extras.util.dot" },
            { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
            { import = "lazyvim.plugins.extras.coding.neogen" },
            { import = "lazyvim.plugins.extras.coding.yanky" },
            { import = "lazyvim.plugins.extras.editor.aerial" },
            { import = "lazyvim.plugins.extras.editor.mini-files" },
            { import = "lazyvim.plugins.extras.editor.navic" },
            { import = "lazyvim.plugins.extras.lang.typescript" },
            { import = "lazyvim.plugins.extras.lang.rust" },
            { import = "lazyvim.plugins.extras.lang.json" },
            { import = "lazyvim.plugins.extras.lang.toml" },
            { import = "lazyvim.plugins.extras.lang.yaml" },
            { import = "lazyvim.plugins.extras.lang.git" },
            { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {} end, },
          },
        })
      '';
  };
  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  xdg.configFile."nvim/parser".source =
    let
      parsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths =
          (pkgs.vimPlugins.nvim-treesitter.withPlugins (
            plugins: with plugins; [
              hyprlang
              lua
              nix
              javascript
              styled
              typescript
              markdown
              markdown_inline
              html
              css
              json
              json5
              jsonc
              jsdoc
              bash
              regex
              c
              vimdoc
            ]
          )).dependencies;
      };
    in
    "${parsers}/parser";

  # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
  xdg.configFile."nvim/lua" = {
    source = ../../dotfiles/nvim/lua;
    recursive = true;
  };

  # fix injection for CSS in JS with Lit (styled injection breaks comment strings)
  xdg.configFile."nvim/after/queries/ecma/injections.scm".text = ''
    ; extends
    (call_expression
      function: (identifier) @_name
      (#any-of? @_name "css" "keyframes")
      arguments: ((template_string) @injection.content
        (#offset! @injection.content 0 1 0 -1)
        (#set! injection.include-children)
        (#set! injection.language "css")))
  '';
}

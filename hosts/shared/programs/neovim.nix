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
      fish
      shfmt

      # LSP
      typescript
      nodePackages_latest.typescript-language-server
      nodePackages_latest.prettier
      lua-language-server
      nixd
      (callPackage ./stylelint-lsp.nix { })
      vscode-langservers-extracted

      # Formatter
      nixpkgs-fmt

      # Telescope
      ripgrep

      # LazyVim 
      # TODO:
      # clean this list
      lazygit
      fd
      ripgrep
      gcc
      libgcc
      libstdcxx5
      stylua
    ];

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];



    extraLuaConfig =
      let
        plugins = with pkgs.vimPlugins; [
          LazyVim
          bufferline-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          cmp_luasnip
          conform-nvim
          dashboard-nvim
          dressing-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          indent-blankline-nvim
          lualine-nvim
          neo-tree-nvim
          neoconf-nvim
          neodev-nvim
          noice-nvim
          nui-nvim
          nvim-cmp
          nvim-lint
          nvim-lspconfig
          nvim-notify
          nvim-spectre
          nvim-treesitter-context
          nvim-ts-autotag
          nvim-ts-context-commentstring
          nvim-treesitter-textobjects
          nvim-treesitter
          nvim-web-devicons
          persistence-nvim
          plenary-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          todo-comments-nvim
          trouble-nvim
          vim-illuminate
          vim-startuptime
          which-key-nvim
          nightfox-nvim
          toggleterm-nvim
          SchemaStore-nvim
          diffview-nvim
          neogit
          cmp-emoji
          undotree
          neogen
          aerial-nvim
          markdown-preview-nvim
          tokyonight-nvim
          typescript-tools-nvim
          nvim-colorizer-lua
          kanagawa-nvim
          sqlite-lua
          yanky-nvim
          { name = "LuaSnip"; path = luasnip; }
          { name = "catppuccin"; path = catppuccin-nvim; }
          { name = "mini.ai"; path = mini-nvim; }
          { name = "mini.bufremove"; path = mini-nvim; }
          { name = "mini.comment"; path = mini-nvim; }
          { name = "mini.indentscope"; path = mini-nvim; }
          { name = "mini.pairs"; path = mini-nvim; }
          { name = "mini.surround"; path = mini-nvim; }
          { name = "mini.animate"; path = mini-nvim; }
          { name = "mini-hipatterns"; path = mini-nvim; }
        ];
        mkEntryFromDrv = drv:
          if lib.isDerivation drv then
            { name = "${lib.getName drv}"; path = drv; }
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
            { import = "lazyvim.plugins.extras.editor.aerial" },
            { import = "lazyvim.plugins.extras.editor.mini-files" },
            { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
            { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
            { import = "lazyvim.plugins.extras.ui.mini-animate" },
            { import = "lazyvim.plugins.extras.coding.yanky" },
            { import = "lazyvim.plugins.extras.lazyrc" },
          },
        })
      '';
  };
  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  xdg.configFile."nvim/parser".source =
    let
      parsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths = (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: with plugins; [
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
        ])).dependencies;
      };
    in
    "${parsers}/parser";

  # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
  xdg.configFile."nvim/lua".source = ../../../dotfiles/nvim/lua;

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

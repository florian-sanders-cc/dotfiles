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
      # LSP
      typescript
      nodePackages_latest.typescript-language-server
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
          emmet-vim
          SchemaStore-nvim
          diffview-nvim
          neogit
          cmp-emoji
          undotree
          neogen
          aerial-nvim
          markdown-preview-nvim
          # TODO: enable when going back to unstable
          # transparent-nvim
          tokyonight-nvim
          typescript-tools-nvim
          vim-visual-multi
          { name = "LuaSnip"; path = luasnip; }
          { name = "catppuccin"; path = catppuccin-nvim; }
          { name = "mini.ai"; path = mini-nvim; }
          { name = "mini.bufremove"; path = mini-nvim; }
          { name = "mini.comment"; path = mini-nvim; }
          { name = "mini.indentscope"; path = mini-nvim; }
          { name = "mini.pairs"; path = mini-nvim; }
          { name = "mini.surround"; path = mini-nvim; }
          { name = "mini.animate"; path = mini-nvim; }
          (pkgs.callPackage ../vimPlugins/file-history.nix { inherit pkgs; })
          (pkgs.callPackage ../vimPlugins/cmp-emmet-vim.nix { inherit pkgs; })
          (pkgs.callPackage ../vimPlugins/transparent-nvim.nix { inherit pkgs; })
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
            { import = "lazyvim.plugins.extras.ui.mini-animate" },
            { import = "lazyvim.plugins.extras.editor.aerial" },
            { import = "lazyvim.plugins.extras.editor.mini-files" },
            { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
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
          # TODO: enable when going back to unstable
          # hyprlang
          lua
          nix
          javascript
          # TODO: enable when going back to unstable
          # styled
          typescript
          markdown
          markdown_inline
          html
          css
          json
          json5
          jsonc
          jsdoc
        ])).dependencies;
      };
    in
    "${parsers}/parser";

  # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
  xdg.configFile."nvim/lua".source = ../../../dotfiles/nvim/lua;
}

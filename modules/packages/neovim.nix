{ lib, pkgs, ... }:

let
  mkEntryFromDrv =
    drv:
    if lib.isDerivation drv then
      {
        name = "${lib.getName drv}";
        path = drv;
      }
    else
      drv;

  lspServers = with pkgs; [
    emmylua-ls
    nil
    nodePackages.bash-language-server
    nodePackages.yaml-language-server
    rust-analyzer
    gopls
    pyright
    clang-tools
    taplo
    marksman
    vtsls
    stylelint-lsp
    vscode-langservers-extracted
  ];

  formatters = with pkgs; [
    stylua
    prettierd
    nixpkgs-fmt
  ];

  plugins = with pkgs.vimPlugins; [
    # Core dependencies
    lazy-nvim
    plenary-nvim
    nvim-web-devicons
    nvim-treesitter
    nvim-treesitter-context
    nvim-treesitter-textobjects

    # LSP & Language Support
    nvim-lspconfig
    lazydev-nvim
    SchemaStore-nvim

    # Completion & Snippets
    blink-cmp
    friendly-snippets

    # Editor Features
    nvim-ts-autotag
    conform-nvim
    flash-nvim
    inc-rename-nvim
    vim-sleuth
    todo-comments-nvim
    trouble-nvim
    persistence-nvim

    # Git Integration
    neogit
    diffview-nvim
    octo-nvim

    # UI & Interface
    nui-nvim
    lualine-nvim
    which-key-nvim
    snacks-nvim
    mini-nvim
    render-markdown-nvim
    markdown-preview-nvim
    (pkgs.callPackage ./neovim-plugins/nordic-nvim.nix { })
    nvim-notify

    # Optional dependencies
    noice-nvim
    telescope-nvim

    # AI Integration
    claudecode-nvim
  ];

  lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);

in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    defaultEditor = true;
    package = pkgs.neovim-nightly;

    extraPackages =
      with pkgs;
      [
        git
        ripgrep
        fd
        unzip
        gcc
      ]
      ++ lspServers
      ++ formatters;

    plugins = with pkgs.vimPlugins; [ lazy-nvim ];

    extraLuaConfig =
      # lua
      ''
        require("config.options");
        require("config.lazy");
      '';
  };

  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    require("lazy").setup({
      defaults = {
        lazy = false,
      },
      performance = {
        reset_packpath = false,
        rtp = {
            reset = false,
            disabled_plugins = {
              "gzip", "matchit", "matchparen", "netrwPlugin",
              "tarPlugin", "tohtml", "tutor", "zipPlugin"
            }
        }
      },
      dev = {
        -- reuse files from pkgs.vimPlugins.*
        path = "${lazyPath}",
        patterns = { "." },
        -- fallback to download
        fallback = false,
      },
      install = {
        -- Safeguard in case we forget to install a plugin with Nix
        missing = false,
      },
      spec = {
        -- import/override with your plugins
        { import = "plugins" },
        { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {} end, },
      },
    })
  '';

  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  xdg.configFile."nvim/parser".source =
    let
      parsers = pkgs.symlinkJoin {
        name = "treesitter-parsers";
        paths =
          (pkgs.vimPlugins.nvim-treesitter.withPlugins (
            plugins: with plugins; [
              diff
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
              rust
              yaml
              vim
              vimdoc
              python
              bash
              go
              scheme
            ]
          )).dependencies;
      };
    in
    "${parsers}/parser";

  # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
  xdg.configFile."nvim/lua" = {
    source = ../../dotfiles/nvim-custom/lua;
    recursive = true;
  };



  # fix injection for CSS in JS with Lit (styled injection breaks comment strings)
  xdg.configFile."nvim/after/queries/ecma/injections.scm".text =
    # scheme
    ''
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

{ pkgs, ... }:

let
  lspServers = with pkgs; [
    lua-language-server
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
    stylelint-ls
    vscode-langservers-extracted
    vscode-json-languageserver
    wc-ls
    kdePackages.full
    typescript
  ];

  formatters = with pkgs; [
    stylua
    prettierd
    nixpkgs-fmt
  ];

  plugins = with pkgs.vimPlugins; [
    # Core dependencies
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
    multicursor-nvim
    grug-far-nvim
    quicker-nvim
    markdown-nvim

    # Git Integration
    neogit
    diffview-nvim
    octo-nvim
    gitsigns-nvim

    # UI & Interface
    nui-nvim
    lualine-nvim
    which-key-nvim
    snacks-nvim
    mini-nvim
    markdown-preview-nvim
    (pkgs.callPackage ./neovim-plugins/nordic-nvim.nix { })
    nvim-notify

    # Optional dependencies
    noice-nvim
    telescope-nvim

    # AI Integration
    claudecode-nvim
    opencode-nvim
  ];

in
{
  programs.neovim =
    {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      defaultEditor = true;
      # package = pkgs.neovim-nightly;

      extraPackages =
        with pkgs;
        [
          git
          ripgrep
          fd
          unzip
          gcc
          ast-grep
        ]
        ++ lspServers
        ++ formatters;

      plugins = plugins;
    };

  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };


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
              go
              scheme
              fish
              qmljs
              ron
            ]
          )).dependencies;
      };
    in
    "${parsers}/parser";


  xdg.configFile."neovide" = {
    source = ../../dotfiles/neovide;
    recursive = true;
  };
}


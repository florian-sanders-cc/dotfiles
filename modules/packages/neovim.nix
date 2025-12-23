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
    typescript
    typescript-go
    copilot-language-server
    emmet-language-server
    gh-actions-ls
  ];

  formatters = with pkgs; [
    stylua
    prettierd
    nixfmt-rfc-style
  ];

  plugins = with pkgs.vimPlugins; [
    # Core dependencies
    plenary-nvim
    nvim-web-devicons
    nvim-treesitter
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
    todo-comments-nvim
    persistence-nvim
    multicursor-nvim
    quicker-nvim
    markdown-nvim
    vim-sleuth # Automatic indent detection

    # Git Integration
    neogit
    diffview-nvim
    litee-nvim
    octo-nvim
    gitsigns-nvim

    # UI & Interface
    lualine-nvim
    which-key-nvim
    snacks-nvim
    mini-nvim
    markdown-preview-nvim
    render-markdown-nvim
    (pkgs.callPackage ./neovim-plugins/nordic-nvim.nix { })
    nvim-notify
    yazi-nvim
    noice-nvim

    # Optional dependencies
    nui-nvim
    telescope-nvim

    # AI Integration
    claudecode-nvim
    codecompanion-nvim
    copilot-lua
  ];

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
        ast-grep
      ]
      ++ lspServers
      ++ formatters;

    plugins = plugins;
  };

  # Full nvim config
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

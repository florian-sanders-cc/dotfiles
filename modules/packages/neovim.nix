{ pkgs, ... }:

let
  lspServers = with pkgs; [
    clang-tools
    cem
    copilot-language-server
    emmet-language-server
    gh-actions-ls
    gopls
    lua-language-server
    marksman
    nil
    bash-language-server
    yaml-language-server
    oxlint
    pyright
    rust-analyzer
    stylelint-ls
    taplo
    typescript
    typescript-go
    vscode-json-languageserver
    vscode-langservers-extracted
    vtsls
    wc-ls
  ];

  formatters = with pkgs; [
    stylua
    prettierd
    nixfmt
  ];

  plugins = with pkgs.vimPlugins; [
    # Core dependencies
    plenary-nvim
    nvim-web-devicons
    nvim-treesitter.withAllGrammars

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
    jj-nvim

    # Git Integration
    neogit
    codediff-nvim
    gitsigns-nvim
    hunk-nvim

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
    withRuby = true;
    withPython3 = true;
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

  # Full nvim config
  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };

  xdg.configFile."neovide" = {
    source = ../../dotfiles/neovide;
    recursive = true;
  };
}

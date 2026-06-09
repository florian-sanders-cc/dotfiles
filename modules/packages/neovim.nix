{ pkgs, ... }:

let
  lspServers = with pkgs; [
    clang-tools
    cem
    emmet-language-server
    gh-actions-ls
    gopls
    lua-language-server
    marksman
    nil
    nixd
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
    # wc-ls
  ];

  formatters = with pkgs; [
    stylua
    prettierd
    nixfmt
  ];

  plugins = with pkgs.vimPlugins; [
    # Core dependencies
    plenary-nvim # Maybe not needed
    nvim-web-devicons
    nvim-treesitter.withAllGrammars

    # LSP & Language Support
    nvim-lspconfig
    SchemaStore-nvim

    # Completion & Snippets
    blink-cmp # Maybe not needed
    friendly-snippets # Maybe not needed

    # Editor Features
    conform-nvim
    flash-nvim
    todo-comments-nvim
    persistence-nvim
    multicursor-nvim
    quicker-nvim
    markdown-nvim # Maybe not needed
    jj-nvim # not needed

    # Git Integration
    codediff-nvim
    hunk-nvim

    # UI & Interface
    lualine-nvim
    which-key-nvim
    snacks-nvim
    mini-nvim
    markdown-preview-nvim # Maybe not needed
    render-markdown-nvim # Maybe not needed
    (pkgs.callPackage ./neovim-plugins/nordic-nvim.nix { })
    yazi-nvim # Maybe not needed
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

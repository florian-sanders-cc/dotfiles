{ pkgs, ... }:

let
  lspServers = with pkgs; [
    clang-tools
    copilot-language-server
    emmet-language-server
    gh-actions-ls
    gopls
    lua-language-server
    marksman
    nil
    nodePackages.bash-language-server
    nodePackages.yaml-language-server
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

  # Provide ecma/jsx/html_tags queries that nvim-treesitter-grammars is missing
  # (needed because JS/TS/HTML queries use `; inherits: ecma,jsx` / `; inherits: html_tags`)
  treesitterQueries = pkgs.vimUtils.buildVimPlugin {
    pname = "nvim-treesitter-queries";
    version = "0.0.1";
    src = pkgs.runCommand "treesitter-queries" { } ''
      mkdir -p $out/queries
      cp -r ${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/ecma $out/queries/
      cp -r ${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/jsx $out/queries/
      cp -r ${pkgs.vimPlugins.nvim-treesitter}/runtime/queries/html_tags $out/queries/
    '';
  };

  plugins = with pkgs.vimPlugins; [
    # Core dependencies
    plenary-nvim
    nvim-web-devicons
    nvim-treesitter.withAllGrammars
    treesitterQueries

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
    kitty-scrollback-nvim

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
    opencode-nvim
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

  xdg.configFile."neovide" = {
    source = ../../dotfiles/neovide;
    recursive = true;
  };
}

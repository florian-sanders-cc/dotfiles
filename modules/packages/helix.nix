{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    # package = pkgs.helix-nightly;

    extraPackages = with pkgs; [
      typescript
      vtsls
      lua-language-server
      nixd
      stylelint-ls
      vscode-langservers-extracted
      vscode-eslint
      nixfmt
      rust-analyzer
    ];
  };
  xdg.configFile."helix/runtime".source = ../../dotfiles/helix/runtime;
  xdg.configFile."helix/config.toml".source = ../../dotfiles/helix/config.toml;
  xdg.configFile."helix/languages.toml".source = ../../dotfiles/helix/languages.toml;
}

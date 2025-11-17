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
      stylelint-lsp
      vscode-langservers-extracted
      nixfmt-rfc-style
      typescript-go
      wc-ls
    ];
  };
  xdg.configFile."helix/runtime".source = ../../dotfiles/helix/runtime;
  xdg.configFile."helix/config.toml".source = ../../dotfiles/helix/config.toml;
  xdg.configFile."helix/languages.toml".source = ../../dotfiles/helix/languages.toml;
}

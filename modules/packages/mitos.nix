{
  lib,
  pkgs,
  ...
}:

let
  # Servers and formatters referenced by dotfiles/mitos/languages.toml.
  # Same approach as neovim (extraPackages) and helix (programs.helix.extraPackages):
  # the editor carries its own servers; nothing leaks to the global PATH.
  #
  # Not included:
  # - wc-language-server: not in nixpkgs (html falls back to
  #   vscode-html-language-server from vscode-langservers-extracted).
  #
  # typescript ships `tsc --lsp` since the native port was merged (7.0),
  # which is what the `tsgo` language server in languages.toml runs.
  lspServers = with pkgs; [
    nil
    nixd
    nixfmt
    prettier
    stylelint-ls
    typescript
    vscode-eslint
    vscode-langservers-extracted
    vtsls
  ];

  # No home-manager module for mitos, so wrap the binary by hand:
  # `ms` sees the servers above on its PATH, the rest of the system does not.
  mitos-wrapped = pkgs.symlinkJoin {
    name = "mitos-wrapped";
    paths = [ pkgs.mitos ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/ms --prefix PATH : ${lib.makeBinPath lspServers}
    '';
  };
in
{
  home.packages = [ mitos-wrapped ];

  xdg.configFile."mitos/config.toml".source = ../../dotfiles/mitos/config.toml;
  xdg.configFile."mitos/languages.toml".source = ../../dotfiles/mitos/languages.toml;
}

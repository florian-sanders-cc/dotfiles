{ pkgs, ... }:

{
  home.packages = [
    pkgs.ghostty
  ];

  xdg.configFile."ghostty" = {
    source = ../../dotfiles/ghostty;
    recursive = true;
  };
}

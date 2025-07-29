{ pkgs, ... }:

{
  home.packages = [
    pkgs.opencode
  ];

  # xdg.configFile."opencode" = {
  #   source = ../../dotfiles/opencode;
  #   recursive = true;
  # };
}

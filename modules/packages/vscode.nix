{ pkgs, ... }:

{
  programs.vscode = {
    enable = false;
    package = pkgs.vscodium;
  };
}

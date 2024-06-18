{ lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      fish
      shfmt
      ripgrep
      lazygit
      fd
    ];
  };

  xdg.configFile."nvim".source = ../../../dotfiles/nvim-ld;
}

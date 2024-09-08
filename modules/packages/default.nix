{
  lib,
  config,
  pkgs,
  ...
}:

let
  specs = import ../../config-specifications.nix;
  commonPackages = with pkgs; [
    # Nix related
    prefetch-npm-deps
    nix-prefetch-git
    nixd
    nixfmt-rfc-style

    # Browsers
    chromium
    firefox-wayland

    # Community
    discord
    slack

    # CLI
    htop
    jq
    s3cmd
    clever-tools

    # Utility
    vlc

    # Dev
    rustup
    gcc
    nodejs
    bun
    obsidian
    neovide
    zellij
    distrobox
  ];
  proPackages = with pkgs; [ random-labels ];

in
{
  imports = [ ./overlays.nix ];
  fonts.packages = with pkgs; [
    nerdfonts
    font-awesome
  ];

  home-manager.users."${config.user.name}" = {
    # Packages with specific config
    imports = [
      ./git.nix
      ./alacritty.nix
      ./fzf.nix
      ./starship.nix
      ./direnv.nix
      ./vscode.nix
      ./zsh.nix
      ./nushell.nix
      ./fish.nix
      ./neovim-fhs.nix
      ./helix.nix
      ./zed.nix
    ];

    user.email = config.user.email;

    # Standard packages
    home.packages = lib.mkMerge [
      commonPackages
      (lib.mkIf (config.user.name == specs.users.pro.name) proPackages)
    ];
  };
}

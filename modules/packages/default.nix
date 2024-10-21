{
  config,
  lib,
  pkgs,
  ...
}:

let
  specs = import ../../config-specifications.nix;
  commonPackages = with pkgs; [
    # Nix related
    nix-prefetch-git
    nixd
    nixfmt-rfc-style
    prefetch-npm-deps

    # Browsers
    chromium
    firefox-wayland

    # Community
    discord
    slack

    # CLI
    clever-tools
    htop
    jq
    s3cmd
    jless
    git-absorb

    # Utility
    vlc

    # Dev
    bun
    difftastic
    distrobox
    gcc
    nodejs
    obsidian
    rustup
    zellij
  ];
  proPackages = with pkgs; [
    random-labels
    clever-switch-profile
  ];

in
{
  imports = [ ./overlays.nix ];
  fonts.packages = with pkgs; [
    font-awesome
    nerdfonts
  ];

  home-manager.users."${config.user.name}" = {
    # Packages with specific config
    imports = [
      ./alacritty.nix
      ./direnv.nix
      ./fish.nix
      ./fzf.nix
      ./git.nix
      ./helix.nix
      ./neovim-fhs.nix
      ./nushell.nix
      ./starship.nix
      ./vscode.nix
      ./zed.nix
      ./zoxide.nix
      ./zsh.nix
    ];

    user.email = config.user.email;
    user.name = config.user.name;

    # Standard packages
    home.packages = lib.mkMerge [
      commonPackages
      (lib.mkIf (config.user.name == specs.users.pro.name) proPackages)
    ];
  };
}

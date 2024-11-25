{
  config,
  lib,
  pkgs,
  currentUser,
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
    gh

    # Utility
    vlc
    inkscape

    # Dev
    bun
    difftastic
    distrobox
    gcc
    nodejs
    obsidian
    rustup
    zellij
    dogdns
    yazi
  ];
  proPackages = with pkgs; [
    random-labels
    clever-switch-profile
    jetbrains.webstorm
  ];

in
{
  imports = [
    ./overlays.nix
    ./steam.nix
  ];

  fonts.packages = with pkgs; [
    font-awesome
    nerdfonts
  ];

  home-manager.users."${currentUser.name}" = {
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

    # Standard packages
    home.packages = lib.mkMerge [
      commonPackages
      (lib.mkIf (currentUser.name == specs.users.pro.name) proPackages)
    ];
  };
}

{
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
    ungoogled-chromium
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
    orca
    geeqie

    # Dev
    bun
    difftastic
    gcc
    nodejs
    obsidian
    rustup
    dogdns
    yazi
    volta
    bat
    usage
  ];
  persoPackages = with pkgs; [
    google-chrome
  ];
  proPackages = with pkgs; [
    random-labels
    clever-switch-profile
    jetbrains.webstorm
  ];
  isGamingEnabled = currentUser.name == specs.users.perso-workstation.name;

in
{
  imports = [
    ./overlays.nix
  ]
  ++ lib.optional isGamingEnabled ./steam.nix
  ++ lib.optional isGamingEnabled ./lutris.nix;

  fonts.packages = with pkgs; [
    font-awesome
    montserrat
    nerd-fonts.jetbrains-mono
    nerd-fonts.zed-mono
    nerd-fonts.fira-mono
    nerd-fonts.liberation
    nerd-fonts.meslo-lg
    nerd-fonts.noto
    nerd-fonts.fira-code
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
      ./zellij.nix
      ./zsh.nix
      ./ghostty.nix
    ];

    # Standard packages
    home.packages = lib.mkMerge [
      commonPackages
      (lib.mkIf (currentUser.name == specs.users.perso-workstation.name) persoPackages)
      (lib.mkIf (currentUser.name == specs.users.perso.name) persoPackages)
      (lib.mkIf (currentUser.name == specs.users.pro.name) proPackages)
    ];
  };
}

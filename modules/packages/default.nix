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
    google-chrome

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
    loupe
    btop

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
    neovide
    claude-code
    gemini-cli
    stu
    stylelint-ls
    lsof
  ];
  proPackages = with pkgs; [
    random-labels
    clever-switch-profile
    # jetbrains.webstorm
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
      ./neovim.nix
      ./starship.nix
      ./vscode.nix
      ./zed.nix
      ./zoxide.nix
      ./zellij.nix
      ./zsh.nix
      ./ghostty.nix
      ./opencode.nix
      ./waybar.nix
      ./yazi.nix
    ];

    # Standard packages
    home.packages = lib.mkMerge [
      commonPackages
      (lib.mkIf (currentUser.name == specs.users.pro.name) proPackages)
    ];
  };
}

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
    nil
    nixfmt
    prefetch-npm-deps

    # Browsers
    ungoogled-chromium
    firefox
    google-chrome
    epiphany

    # Community
    discord
    slack

    # CLI
    clever-tools
    jq
    s3cmd
    jless
    git-absorb
    gh
    sops
    jjui

    # Utility
    vlc
    inkscape
    loupe
    btop

    # Dev
    bun
    gcc
    nodejs
    obsidian
    rustup
    doggo
    yazi
    bat
    usage
    neovide
    claude-code
    opencode
    opencode-desktop
    stu
    stylelint-ls
    lsof
    github-copilot-cli
    handy
    wtype
    playwright-cli
    rtk
    nono
  ];
  proPackages = with pkgs; [
    # jetbrains.webstorm
    glab
    random-labels
  ];
  isGamingEnabled = currentUser.name == specs.users.perso-workstation.name;

in
{
  imports = [
    ./overlays.nix
    ./fwupd.nix
  ]
  ++ lib.optional isGamingEnabled ./steam.nix
  ++ lib.optional isGamingEnabled ./lutris.nix;
  services.flatpak.enable = true;

  fonts.packages = with pkgs; [
    font-awesome
    montserrat
    nerd-fonts.jetbrains-mono
  ];

  home-manager.users."${currentUser.name}" = {
    # Packages with specific config
    imports = [
      ./agents.nix
      ./alacritty.nix
      ./claude-code.nix
      ./codediff-ann.nix
      ./direnv.nix
      ./fish.nix
      ./fzf.nix
      ./ghostty.nix
      ./git.nix
      ./helix.nix
      ./kitty.nix
      ./mise.nix
      ./neovim.nix # Full-featured Neovim (command: nvim)
      ./nono.nix
      ./opencode.nix
      ./pi.nix
      ./pw-broker.nix
      ./starship.nix
      ./vscode.nix
      ./warp.nix
      ./waybar.nix
      ./yazi.nix
      ./zed.nix
      ./zellij.nix
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

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
    volta
    bat
    usage
    neovide
    claude-code
    opencode
    stu
    stylelint-ls
    lsof
    github-copilot-cli
    warp-terminal-wayland
    handy
    wtype
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
    ./fwupd.nix
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
      ./neovim.nix # Full-featured Neovim (command: nvim)
      # ./neovim-alt.nix
      # ./nvim-mini.nix # Minimal Neovim (command: nvim-mini)
      ./starship.nix
      ./vscode.nix
      ./zed.nix
      ./zoxide.nix
      ./kitty.nix
      ./zellij.nix
      ./zsh.nix
      ./ghostty.nix
      ./opencode.nix
      ./waybar.nix
      ./yazi.nix
      ./warp.nix
    ];

    # Standard packages
    home.packages = lib.mkMerge [
      commonPackages
      (lib.mkIf (currentUser.name == specs.users.pro.name) proPackages)
    ];
  };
}

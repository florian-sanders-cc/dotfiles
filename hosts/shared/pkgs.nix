{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prefetch-npm-deps
    nix-prefetch-git
    chromium
    discord
    firefox-wayland
    htop
    jq
    vlc
    s3cmd
    slack
    discord
    nodejs
    bun
    nvtop
    obsidian
    tuxedo-rs
    tailor-gui
    (callPackage ./programs/random-labels.nix { })
    (callPackage ./programs/clever-tools.nix { })
  ];

  fonts.packages = with pkgs; [
    nerdfonts
    font-awesome
  ];
}

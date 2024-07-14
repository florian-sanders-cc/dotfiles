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
    obsidian
    neovide
    zellij
    (callPackage ./programs/random-labels.nix { })
    clever-tools
    zed-editor
    distrobox
  ];

  fonts.packages = with pkgs; [
    nerdfonts
    font-awesome
  ];
}

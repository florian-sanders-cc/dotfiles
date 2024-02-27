{ pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
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
        (callPackage ./programs/random-labels.nix {})
        (callPackage ./programs/clever-tools.nix {})
    ];

    fonts.packages = with pkgs; [
        nerdfonts
        font-awesome
    ];
}

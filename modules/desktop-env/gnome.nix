# TODO: rely on specialisations and maybe spread this file content across others
{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf (config.desktop == "gnome") {
    system.nixos.tags = [ "gnome" ];
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.gnome.gnome-keyring.enable = true;
    environment.gnome.excludePackages =
      (with pkgs; [ gnome-tour ])
      ++ (with pkgs; [
        cheese # webcam tool
        gnome-music
        geary # email reader
        gnome-characters
        epiphany
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        yelp # Help view
        gnome-contacts
        gnome-initial-setup
      ]);
    # programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
      gnome-tweaks
      gnomeExtensions.dash-to-panel
      gnomeExtensions.resource-monitor
      gnomeExtensions.appindicator
      adwaita-icon-theme
      wl-clipboard
      xdotool
    ];
    security.pam.services.gdm.enableGnomeKeyring = true;
    services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  };
}

# TODO: rely on specialisations and maybe spread this file content across others
{
  pkgs,
  lib,
  ...
}:

{
  system.nixos.tags = [ "gnome" ];
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
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

  # Set default terminal to kitty
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/desktop/default-applications/terminal" = {
          exec = "kitty";
          exec-arg = "-e";
        };
      };
    }
  ];
}

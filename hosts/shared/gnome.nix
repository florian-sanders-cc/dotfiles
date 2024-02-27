{ pkgs, ... }:

{
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.gnome.gnome-keyring.enable = true;
    environment.gnome.excludePackages = (with pkgs; [
        gnome-tour
        ]) ++ (with pkgs.gnome; [
            cheese # webcam tool
            gnome-music
            geary # email reader
            gnome-characters
            tali # poker game
            iagno # go game
            hitori # sudoku game
            atomix # puzzle game
            yelp # Help view
            gnome-contacts
            gnome-initial-setup
        ]);
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
        gnome.gnome-tweaks
        gnomeExtensions.dash-to-panel
        gnomeExtensions.resource-monitor
        gnomeExtensions.appindicator
    ];
}

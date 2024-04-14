{ pkgs, ... }:

{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    libnotify
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
  ];

  # qt = {
  #   enable = true;
  #   platformTheme = "gnome";
  #   style = "adwaita-dark";
  # };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];
}

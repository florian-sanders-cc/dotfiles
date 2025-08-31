{
  pkgs,
  lib,
  currentUser,
  ...
}:

{
  system.nixos.tags = [ "plasma" ];
  home-manager.users."${currentUser.name}" = {
    xdg.configFile."kglobalshortcutsrc" = {
      source = ../../dotfiles/plasma/kglobalshortcutsrc;
    };
    xdg.configFile."kwalletrc" = {
      source = ../../dotfiles/plasma/kwalletrc;
    };
  };

  services.displayManager = {
    sddm.enable = true;
    sddm.wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    kdePackages.ksshaskpass
    kdePackages.partitionmanager
    xdotool
  ];

  programs.ssh = {
    enableAskPassword = true;
    askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    startAgent = true;
  };
  environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
  ];

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];
  # TODO: move these to security
  security.pam.services.sddm.enableKwallet = true;
  security.pam.services.login.enableKwallet = true;
  security.pam.services.kdewallet.enableKwallet = true;
}

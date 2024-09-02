{
  inputs,
  config,
  lib,
  ...
}:

{
  config = lib.mkIf (config.desktop == "niri") {
    services = {
      # displayManager.cosmic-greeter.enable = true;
      xserver.displayManager.gdm.enable = true;
      desktopManager.cosmic.enable = true;
    };
    system.nixos.tags = [ "cosmic" ];
  };
}

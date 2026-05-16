{ config, pkgs, lib, ... }:

{
  # TUXEDO EC driver: required for proper power limit negotiation with the EC.
  # Without it, the EC falls back to a conservative 35W PL1 cap, throttling
  # all cores to ~1.2 GHz regardless of load or AC state.
  hardware.tuxedo-drivers.enable = true;

  # TUXEDO Control Center — perso & pro only (laptop with tuxedo-drivers)
  boot.kernelModules =  [ "tuxedo_io" ];
  services.dbus.packages = [ pkgs.tuxedo-control-center ];
  services.udev.packages = [ pkgs.tuxedo-control-center ];
  systemd.packages = [ pkgs.tuxedo-control-center ];
  # systemd.packages does not set wantedBy — must be explicit
  systemd.services.tccd.wantedBy = [ "multi-user.target" ];
  systemd.services.tccd-sleep.wantedBy = [ "sleep.target" ];
  # Add nvidia-smi to tccd PATH so GPU stats polling works
  systemd.services.tccd.path = lib.mkIf config.nvidia.enable [
    config.hardware.nvidia.package
  ];
  environment.systemPackages = [ pkgs.tuxedo-control-center ];
}

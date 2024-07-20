{ pkgs, lib, ... }:

{
  system.nixos.tags = [ "intel" ];
  hardware.graphics = lib.mkDefault {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
}

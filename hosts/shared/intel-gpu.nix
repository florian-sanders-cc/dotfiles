{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
}

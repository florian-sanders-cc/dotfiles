{
  pkgs,
  lib,
  config,
  currentUser,
  ...
}:

{
  options = {
    lutris = {
      enable = lib.mkEnableOption "Lutris";
    };
  };

  config = {
    home-manager.users."${currentUser.name}" = {

      # Standard packages
      home.packages = [
        pkgs.lutris
        pkgs.wineWowPackages.waylandFull
        pkgs.winetricks
      ];
    };
  };
}

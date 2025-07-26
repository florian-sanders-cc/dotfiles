{
  pkgs,
  currentUser,
  ...
}:

{
  home-manager.users."${currentUser.name}" = {
    # Standard packages
    home.packages = [
      pkgs.lutris
      pkgs.wineWowPackages.waylandFull
      pkgs.winetricks
    ];
  };
}

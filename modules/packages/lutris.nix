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
      pkgs.wineWow64Packages.waylandFull
      pkgs.winetricks
    ];
  };
}

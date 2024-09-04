{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (buildFHSUserEnv {
      name = "zed";
      targetPkgs = pkgs: [ zed-latest ];
      runScript = "zed";
    })
  ];

  xdg.configFile."zed" = {
    source = ../../dotfiles/zed;
    recursive = true;
  };

}

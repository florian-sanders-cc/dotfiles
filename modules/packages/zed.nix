{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    (buildFHSUserEnv {
      name = "zed";
      targetPkgs = pkgs: [ zed-latest ];
      runScript = "zed";
    })
  ];

  xdg.configFile."zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/dotfiles/zed/settings.json";
  xdg.configFile."zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/dotfiles/zed/keymap.json";
}

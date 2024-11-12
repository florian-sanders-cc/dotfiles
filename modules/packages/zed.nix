{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    (buildFHSUserEnv {
      name = "zed";
      targetPkgs = pkgs: [
        zed-latest
        openssl
      ];
      runScript = "zed";
      extraInstallCommands = ''
        ln -s "${zed-latest}/share" "$out/"
      '';
    })
  ];

  xdg.configFile."zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/dotfiles/zed/settings.json";
  xdg.configFile."zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/dotfiles/zed/keymap.json";
}

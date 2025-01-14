{
  pkgs,
  config,
  currentUser,
  ...
}:

{
  home.packages = with pkgs; [
    # (buildFHSUserEnv {
    #   name = "zed";
    #   targetPkgs = pkgs: [
    #     zed-latest
    #     openssl
    #   ];
    #   runScript = "zed";
    #   extraInstallCommands = ''
    #     ln -s "${zed-latest}/share" "$out/"
    #   '';
    # })
    zed-editor
  ];

  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/zed/settings.json";
  xdg.configFile."zed/keymap.json".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/zed/keymap.json";
}

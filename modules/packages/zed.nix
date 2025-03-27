{
  pkgs,
  config,
  currentUser,
  ...
}:

{
  home.packages = with pkgs; [
    zed-preview
    # zed-editor
  ];

  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/zed/settings.json";
  xdg.configFile."zed/keymap.json".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/zed/keymap.json";
  xdg.configFile."zed/tasks.json".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/zed/tasks.json";
}

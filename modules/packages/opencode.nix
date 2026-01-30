{
  config,
  currentUser,
  ...
}:

{
  # Use mkOutOfStoreSymlink for mutable configs that can be edited without rebuild
  xdg.configFile."opencode/opencode.json".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/opencode/opencode.json";

  xdg.configFile."opencode/agents".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/opencode/agents";
}

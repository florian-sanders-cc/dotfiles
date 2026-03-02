{
  config,
  currentUser,
  ...
}:

{
  # Use mkOutOfStoreSymlink for mutable configs that can be edited without rebuild
  # ~/.claude/ is Claude Code's config dir (not XDG-based, so we use home.file)
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/claude-code/skills";
}

{
  config,
  currentUser,
  ...
}:

{
  # Generic agent skills directory — used by pi, OpenCode, and any future
  # agent that follows the Agent Skills standard and scans ~/.agents/skills/.
  home.file.".agents/skills".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/agents/skills";

  # AGENTS.md — loaded by pi via walk-up from cwd and explicit --read-file
  home.file.".config/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/agents/AGENTS.md";
}

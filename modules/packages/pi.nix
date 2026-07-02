{
  config,
  pkgs,
  currentUser,
  ...
}:

let
  piDotfiles = "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/pi";
in
{
  home.packages = [
    pkgs.pi-coding-agent
    pkgs.pi-handoff
  ];

  home.file = {
    ".pi/agent/extensions".source = config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/extensions";
    ".pi/agent/agents".source = config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/agents";
    ".pi/agent/prompts".source = config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/prompts";
    ".pi/agent/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/keybindings.json";
  };
}

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
    ".pi/agent/skills".source = config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/skills";
    ".pi/agent/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/keybindings.json";
    ".pi/agent/APPEND_SYSTEM.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/APPEND_SYSTEM.md";
      force = true;
    };
    ".pi/agent/nix-extensions/pi-rtk-bash".source = "${pkgs.pi-rtk-bash}/lib/node_modules/pi-rtk-bash";
    ".pi/agent/settings.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/settings.json";
      force = true;
    };
  };
}

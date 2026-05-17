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
  ];

  home.file = {
    ".pi/agent/extensions".source = config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/extensions";
    ".pi/agent/prompts".source = config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/prompts";
    ".pi/agent/keybindings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${piDotfiles}/keybindings.json";
  };
}

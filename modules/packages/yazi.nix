{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  # Copy custom config files
  xdg.configFile."yazi/yazi.toml" = {
    source = ../../dotfiles/yazi/yazi.toml;
  };

  xdg.configFile."yazi/keymap.toml" = {
    source = ../../dotfiles/yazi/keymap.toml;
  };

  xdg.configFile."yazi/theme.toml" = {
    source = ../../dotfiles/yazi/theme.toml;
  };
}

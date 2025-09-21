{ ... }:

{
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
    enableZshIntegration = false;
  };

  xdg.configFile."zellij" = {
    source = ../../dotfiles/zellij;
    recursive = true;
  };
}

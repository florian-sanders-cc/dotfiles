{
  ...
}:

{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-frappe";
      # simplified_ui = true;
      # default_layout = "compact";
      pane_frames = false;
    };
    enableFishIntegration = false;
    enableZshIntegration = false;
  };

  xdg.configFile."zellij/layouts" = {
    source = ../../dotfiles/zellij/layouts;
    recursive = true;
  };
}

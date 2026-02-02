{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    settings = {
      font_size = 12.0;
      font_family = "JetBrainsMono NFM Thin";
      bold_font = "JetBrainsMono NFM Light";
      italic_font = "JetBrainsMono NFM Thin Italic";
      bold_italic_font = "JetBrainsMono NFM Light Italic";
      tab_bar_style = "powerline";
      tab_bar_edge = "top";
      window_padding_width = 8;
      confirm_os_window_close = 0;
      modify_font = "cell_height 140%";
      shell_integration = true;
      allow_remote_control = true;
      listen_on = "unix:/tmp/kitty";
      # Enable splits layout for vsplit/hsplit support
      enabled_layouts = "splits,stack";
      # Colors matched from Alacritty config
      background = "#242933";
      foreground = "#BBBDAF";
      selection_background = "#F0DFAF";
      selection_foreground = "#000000";
      url_color = "#8FB4D8";
      cursor = "#a3be8c";
      active_border_color = "#A3D6A9";
      inactive_border_color = "#727C7C";
      bell_border_color = "#C7A9D9";
      # Normal colors (0-7)
      color0 = "#191C1D";
      color1 = "#BD6062";
      color2 = "#A3D6A9";
      color3 = "#F0DFAF";
      color4 = "#8FB4D8";
      color5 = "#C7A9D9";
      color6 = "#B6D7A8";
      color7 = "#BDC5BD";
      # Bright colors (8-15)
      color8 = "#727C7C";
      color9 = "#D18FAF";
      color10 = "#B7CEB0";
      color11 = "#BCBCBC";
      color12 = "#E0CF9F";
      color13 = "#C7A9D9";
      color14 = "#BBDA97";
      color15 = "#BDC5BD";
    };
    actionAliases = {
      kitty_scrollback_nvim = "kitten ${pkgs.vimPlugins.kitty-scrollback-nvim}/python/kitty_scrollback_nvim.py";
    };
    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+h" = "kitty_scrollback_nvim";
      "ctrl+shift+e" = "launch --type=tab --cwd=current nvim .";
      "ctrl+shift+d" = "launch --type=tab --cwd=current nvim -c DiffviewOpen";
      # AI split panes (Warp-like feature)
      "ctrl+shift+a" = "launch --type=window --location=vsplit --cwd=current opencode";
      # Fork: continue most recent session in a new split
      "ctrl+shift+f" =
        "launch --type=window --location=vsplit --cwd=current fish -c 'set -l sid (opencode session list --format=json 2>/dev/null | jq -r \".[0].id\" 2>/dev/null); if test -n \"$sid\" -a \"$sid\" != \"null\"; opencode --session \"$sid\"; else; opencode; end'";
      "ctrl+alt+left" = "previous_window";
      "ctrl+alt+right" = "next_window";
    };
  };
}

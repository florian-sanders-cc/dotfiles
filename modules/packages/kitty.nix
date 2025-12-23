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
      scrollback_pager = "nvim --cmd 'set eventignore=FileType' -c 'tnoremap <buffer> <Esc><Esc> <C-\\><C-n> | nnoremap <buffer> q :q!<CR> | call nvim_open_term(0, {}) | set nomodified nolist | normal G' -";
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
  };
}

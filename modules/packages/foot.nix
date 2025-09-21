{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font Mono:size=12:style=Light";
        shell = "fish";
        font-bold = "JetBrainsMono Nerd Font Mono:size=12:style=Regular";
        font-italic = "JetBrainsMono Nerd Font Mono:size=12:style=Light Italic";
        font-bold-italic = "JetBrainsMono Nerd Font Mono:size=12:style=Regular Italic";
        line-height = 24;

        pad = "5x0";
      };

      colors = {
        foreground = "BBBDAF";
        background = "242933";

        # Cursor colors
        cursor = "191C1D 8FB4D8";

        # Selection colors
        selection-foreground = "000000";
        selection-background = "F0DFAF";

        # Normal colors
        regular0 = "191C1D"; # black
        regular1 = "BD6062"; # red
        regular2 = "A3D6A9"; # green
        regular3 = "F0DFAF"; # yellow
        regular4 = "8FB4D8"; # blue
        regular5 = "C7A9D9"; # magenta
        regular6 = "B6D7A8"; # cyan
        regular7 = "BDC5BD"; # white

        # Bright colors
        bright0 = "727C7C"; # bright black
        bright1 = "D18FAF"; # bright red
        bright2 = "B7CEB0"; # bright green
        bright3 = "BCBCBC"; # bright yellow
        bright4 = "E0CF9F"; # bright blue
        bright5 = "C7A9D9"; # bright magenta
        bright6 = "BBDA97"; # bright cyan
        bright7 = "BDC5BD"; # bright white
      };

      key-bindings = {
        search-start = "Control+Shift+r";
        spawn-terminal = "Control+Shift+n";
        quit = "Control+Shift+q";
      };

      scrollback = {
        lines = 10000;
        multiplier = 3;
      };
    };
  };
}

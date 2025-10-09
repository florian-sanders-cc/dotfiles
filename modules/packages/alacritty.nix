{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "none";
        dimensions.columns = 120;
        dimensions.lines = 30;
        padding.x = 10;
        padding.y = 10;
      };

      keyboard.bindings = [
        {
          key = "N";
          mods = "Control|Shift";
          action = "SpawnNewInstance";
        }
        {
          key = "Q";
          mods = "Control";
          action = "ReceiveChar";
        }
      ];

      font = {
        offset = {
          y = 12;
        };
        glyph_offset = {
          y = 6;
        };
        size = 12;
        normal = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Light";
        };
        bold = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Regular";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Regular Italic";
        };
      };

      colors = {
        cursor = {
          cursor = "#a3be8c";
          text = "#191C1D";
        };
        primary = {
          background = "#242933";
          foreground = "#BBBDAF";
        };
        normal = {
          black = "#191C1D";
          red = "#BD6062";
          green = "#A3D6A9";
          yellow = "#F0DFAF";
          blue = "#8FB4D8";
          magenta = "#C7A9D9";
          cyan = "#B6D7A8";
          white = "#BDC5BD";
        };
        bright = {
          black = "#727C7C";
          red = "#D18FAF";
          green = "#B7CEB0";
          yellow = "#BCBCBC";
          blue = "#E0CF9F";
          magenta = "#C7A9D9";
          cyan = "#BBDA97";
          white = "#BDC5BD";
        };
        selection = {
          text = "#000000";
          background = "#F0DFAF";
        };
      };
    };
  };
}

{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "none";
        dimensions.columns = 120;
        dimensions.lines = 30;
        padding.x = 0;
        padding.y = 0;
        opacity = 0.9;
      };

      keyboard.bindings = [
        {
          key = "Q";
          mods = "Control|Shift";
          action = "Quit";
        }
        {
          key = "N";
          mods = "Control|Shift";
          action = "SpawnNewInstance";
        }
      ];

      font = {
        normal = {
          family = "JetbrainsMonoNL Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMonoNL Nerd Font Mono";
          style = "SemiBold";
        };
        bold_italic = {
          family = "JetBrainsMonoNL Nerd Font Mono";
          style = "SemiBold Italic";
        };
      };

      colors = {
        cursor = {
          cursor = "#BD6062";
          text = "#FEFEFE";
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

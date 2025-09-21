{ ... }:

{
  programs.rio = {
    enable = true;
    settings = {
      confirm-before-quit = false;
      line-height = 1.4;

      fonts = {
        size = 16;
        use-drawable-chars = false;
        regular = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Normal";
          width = "Normal";
          weight = 300;
        };
        bold = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Normal";
          width = "Normal";
          weight = 400;
        };
        italic = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Italic";
          width = "Normal";
          weight = 300;
        };
        bold-italic = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Italic";
          width = "Normal";
          weight = 400;
        };
      };

      colors = {
        background = "#2e3440";
        foreground = "#d8dee9";
        selection-background = "#eceff4";
        selection-foreground = "#4c566a";
        cursor = "#eceff4";
        black = "#3b4252";
        red = "#bf616a";
        green = "#a3be8c";
        yellow = "#ebcb8b";
        blue = "#81a1c1";
        magenta = "#b48ead";
        cyan = "#88c0d0";
        white = "#e5e9f0";
        light_black = "#4c566a";
        light_red = "#bf616a";
        light_green = "#a3be8c";
        light_yellow = "#ebcb8b";
        light_blue = "#81a1c1";
        light_magenta = "#b48ead";
        light_cyan = "#8fbcbb";
        light_white = "#eceff4";
      };

      # hints = {
      #   # Characters used for hint labels
      #   alphabet = "jfkdls;ahgurieowpq";
      #
      #   # URL hint example
      #   rules = [
      #     {
      #       regex = "(https://|http://)[^\u{0000}-\u{001F}\u{007F}-\u{009F}<>\"\\s{-}\\^⟨⟩`\\\\]+";
      #       hyperlinks = true;
      #       post-processing = true;
      #       persist = false;
      #       action = {
      #         command = "xdg-open"; # Linux/BSD
      #       };
      #       binding = {
      #         key = "O";
      #         mods = [ "Control" "Shift" ];
      #       };
      #     }
      #   ];
      # };

      navigation = {
        mode = "bookmark";
        use-split = true;
        unfocused-split-opacity = 0.8;
        hide-if-single = true;
      };

      padding-x = 5;
      padding-y = [
        0
        0
      ];

      renderer = {
        performance = "high";
        backend = "Automatic";
        disable-unfocused-render = false;
        disable-occluded-render = true;
      };

      bindings = {
        keys = [
          # Enable VI mode on escape, when not in VI mode.
          {
            key = "space";
            "with" = "alt | shift";
            mode = "~vi";
            action = "ToggleVIMode";
          }
        ];
      };
    };
  };
}

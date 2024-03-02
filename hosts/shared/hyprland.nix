{ pkgs, ... }:

{
  home.packages = with pkgs; [ 
      swaylock
      swayosd
      hyprpaper
      wl-clipboard
      cliphist
      xfce.thunar
      swaynotificationcenter
      fuzzel
      wleave
      pavucontrol
      waybar
      slurp
      grim
      grimblast
    ];

    home.file.".config/waybar".source = ../../dotfiles/waybar;
    home.file.".config/waybar/config.jsonc".source = ../../dotfiles/waybar/config.jsonc;
    home.file.".config/waybar/modules.jsonc".source = ../../dotfiles/waybar/modules.jsonc;
    home.file.".config/waybar/style.css".source = ../../dotfiles/waybar/style.css;
    home.file.".config/waybar/launch.sh" = {
        source = ../../dotfiles/waybar/launch.sh;
        executable = true;
    };
    home.file.".config/wleave".source = ../../dotfiles/wleave;
    home.file.".config/fuzzel".source = ../../dotfiles/fuzzel;
    home.file.".config/swaylock".source = ../../dotfiles/swaylock;
    home.file.".config/hypr/".source = ../../dotfiles/hypr;
}



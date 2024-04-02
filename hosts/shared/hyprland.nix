{ pkgs, ... }:

{
  services.gpg-agent = {
    enable = true;
  };

  programs.keychain = {
    enable = true;
    keys = [ "id_ed25519" ];
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 13;
  };

  gtk = {
    enable = true;
    # theme = {
    #   package = pkgs.flat-remix-gtk;
    #   name = "Flat-Remix-GTK-Grey-Darkest";
    # };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };

  home.packages = with pkgs; [
    swaylock
    swayosd
    hyprpaper
    wl-clipboard
    cliphist
    xfce.thunar
    swaynotificationcenter
    fuzzel
    wlogout
    pavucontrol
    waybar
    slurp
    grim
    grimblast
    lxqt.lxqt-policykit
    gtk4
    libadwaita
  ];

  home.file.".config/waybar".source = ../../dotfiles/waybar;
  home.file.".config/waybar/config.jsonc".source = ../../dotfiles/waybar/config.jsonc;
  home.file.".config/waybar/modules.jsonc".source = ../../dotfiles/waybar/modules.jsonc;
  home.file.".config/waybar/style.css".source = ../../dotfiles/waybar/style.css;
  home.file.".config/waybar/launch.sh" = {
    source = ../../dotfiles/waybar/launch.sh;
    executable = true;
  };
  home.file.".config/fuzzel".source = ../../dotfiles/fuzzel;
  home.file.".config/swaylock".source = ../../dotfiles/swaylock;
  home.file.".config/hypr/".source = ../../dotfiles/hypr;
}



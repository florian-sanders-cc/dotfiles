{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.desktop == "niri") {
    system.nixos.tags = [ "niri" ];

    environment.systemPackages = with pkgs; [
      niri
      wl-clipboard
      cliphist
      fuzzel
      pavucontrol
      gtk4
      libadwaita
      xdg-desktop-portal-gtk
      xdotool
      xdg-desktop-portal-gnome
      seahorse
      polkit_gnome
      nautilus
      xwayland-satellite
      wlogout
      swaybg
      swayosd
      adwaita-icon-theme
      kdePackages.breeze-icons
      (pkgs.catppuccin-sddm.override {
        flavor = "mocha";
        font = "Noto Sans";
        fontSize = "14";
        background = ../../dotfiles/wallpapers/wallpaper-lines.png;
        loginBackground = true;
      })
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      configPackages = [ pkgs.niri ];
    };

    services = {
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        theme = "catppuccin-mocha";
      };
      displayManager.sessionPackages = [ pkgs.niri ];
    };

    programs.xwayland.enable = true;
    programs.dconf.enable = true;

    security.pam.services = {
      login.enableGnomeKeyring = true;
      swaylock = { };
    };
    home-manager.users."${config.user.name}" = {

      home.file.".config/niri" = {
        source = ../../dotfiles/niri;
        recursive = true;
      };
      home.file.".config/waybar".source = ../../dotfiles/waybar;
      home.file.".config/waybar/config.jsonc".source = ../../dotfiles/waybar/config.jsonc;
      home.file.".config/waybar/modules.jsonc".source = ../../dotfiles/waybar/modules.jsonc;
      home.file.".config/waybar/style.css".source = ../../dotfiles/waybar/style.css;
      home.file.".config/fuzzel".source = ../../dotfiles/fuzzel;
      home.file.".config/wlogout" = {
        source = ../../dotfiles/wlogout;
        recursive = true;
      };
      # home.file.".config/mako".source = ../../dotfiles/mako;

      programs.waybar = {
        enable = true;
        systemd.enable = true;
        systemd.target = "niri.service";
      };

      programs.swaylock = {
        enable = true;
        settings = {
          image = "${../../dotfiles/wallpapers/wallpaper-lines.png}";
          indicator-caps-lock = true;
        };
      };

      gtk = {
        enable = true;
        theme = {
          name = "Breeze-Dark";
          package = pkgs.libsForQt5.breeze-gtk;
        };
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        cursorTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
      };

      dconf = {
        enable = true;
        settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };

      services = {
        # mako.enable = true;
        swaync = {
          enable = true;
        };
        gnome-keyring = {
          enable = true;
          components = [
            "pkcs11"
            "secrets"
            "ssh"
          ];
        };
      };

      home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";

      systemd.user.services.swaybg = {
        Unit = {
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "niri.service" ];
        };
        Service = {
          Restart = "on-failure";
          ExecStart = lib.escapeShellArgs [
            (lib.getExe pkgs.swaybg)
            "--mode"
            "fill"
            "--image"
            ../../dotfiles/wallpapers/wallpaper-waves.png
          ];
        };
      };

      # systemd.user.services.xwayland-satellite = {
      #   Unit = {
      #     Description = "Xwayland outside your Wayland";
      #     BindsTo = "graphical-session.target";
      #     PartOf = "graphical-session.target";
      #     After = "graphical-session.target";
      #     Requisite = "graphical-session.target";
      #   };
      #   Service = {
      #     Type = "notify";
      #     NotifyAccess = "all";
      #     # Environment = "PATH=${pkgs.xwayland}/bin";
      #     ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      #     StandardOutput = "journal";
      #   };
      #   Install.WantedBy = [ "graphical-session.target" ];
      # };
    };

  };
}
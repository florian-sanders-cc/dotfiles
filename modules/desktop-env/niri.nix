{ lib
, pkgs
, currentUser
, ...
}:

{
  system.nixos.tags = [ "niri" ];

  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    blueberry
    cliphist
    fuzzel
    gtk4
    kdePackages.breeze-icons
    libadwaita
    nautilus
    pavucontrol
    polkit_gnome
    seahorse
    swaybg
    swayosd
    wl-clipboard
    xwayland-satellite
    swaynotificationcenter
    gnome-calculator
    gnome-disk-utility
    seahorse
  ];

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  programs.xwayland.enable = true;
  programs.dconf.enable = true;

  security.pam.services = {
    swaylock = { };
  };

  home-manager.users."${currentUser.name}" = {

    imports = [
      ../packages/wlogout.nix
      ../packages/waybar.nix
    ];

    home.file.".config/niri" = {
      source = ../../dotfiles/niri;
      recursive = true;
    };
    home.file.".config/fuzzel".source = ../../dotfiles/fuzzel;

    home.sessionVariables = {
      WAYLAND_DISPLAY = "wayland-1";
    };

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
        package = pkgs.kdePackages.breeze-gtk;
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
    };

    services = {
      swaync = {
        enable = true;
      };
      gnome-keyring = {
        enable = true;
        components = [
          "secrets"
          "ssh"
        ];
      };
    };

    systemd.user.services.niri = {
      Unit = {
        Description = "A scrollable-tiling Wayland compositor";
        BindsTo = "graphical-session.target";
        Before = "graphical-session.target";
        Wants = "graphical-session-pre.target";
        After = "graphical-session-pre.target";
      };
      Service = {
        Slice = "session.slice";
        Type = "notify";
        ExecStart = "${pkgs.niri}/bin/niri --session";
      };
    };

    systemd.user.services.swaybg = {
      Unit = {
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Restart = "on-failure";
        ExecStart = lib.escapeShellArgs [
          (lib.getExe pkgs.swaybg)
          "--mode"
          "fill"
          "--image"
          "${pkgs.wallpapers}/nixos-catppuccin-mocha.png"
        ];
      };
    };

    systemd.user.services.xwayland-satellite = {
      Unit = {
        Description = "Xwayland outside your Wayland";
        BindsTo = "graphical-session.target";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
        Requisite = "graphical-session.target";
      };
      Service = {
        Type = "notify";
        NotifyAccess = "all";
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
        StandardOutput = "journal";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}

{
  pkgs,
  currentUser,
  ...
}:

{
  system.nixos.tags = [ "niri" ];

  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    adw-gtk3
    cliphist
    gtk4
    libadwaita
    nautilus
    pavucontrol
    polkit_gnome
    wl-clipboard
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    xwayland-satellite
    gnome-calculator
    gnome-disk-utility
    seahorse
    noctalia-qs
    swww
    niri-smart-focus
    kdePackages.qtwayland
  ];

  services.orca.enable = true;

  services.displayManager = {
    gdm = {
      enable = true;
      wayland = true;
    };
    defaultSession = "niri";
    sessionPackages = [ pkgs.niri ];
  };

  programs.xwayland.enable = true;
  security.pam.services = {
    swaylock = { };
  };
  services.upower.enable = true;

  # XDG Desktop Portal for GNOME app integration
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  home-manager.users."${currentUser.name}" = {

    home.file.".config/niri" = {
      source = ../../dotfiles/niri;
      recursive = true;
    };

    home.sessionVariables = {
      WAYLAND_DISPLAY = "wayland-1";
    };

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
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
      settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
        "org/gnome/desktop/default-applications/terminal" = {
          exec = "alacritty";
          exec-arg = "-e";
        };
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

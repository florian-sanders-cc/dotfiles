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
    cliphist
    gtk4
    kdePackages.breeze-icons
    libadwaita
    nautilus
    pavucontrol
    polkit_gnome
    wl-clipboard
    xwayland-satellite
    gnome-calculator
    gnome-disk-utility
    seahorse
    noctalia-qs
    swww
    niri-smart-focus
  ];

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

  home-manager.users."${currentUser.name}" = {

    imports = [
      ../packages/wlogout.nix
    ];

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
        name = "Breeze-Dark";
        package = pkgs.kdePackages.breeze-gtk;
      };
      iconTheme = {
        name = "Breeze-Dark";
        package = pkgs.kdePackages.breeze-gtk;
      };
      cursorTheme = {
        name = "Breeze-Dark";
        package = pkgs.kdePackages.breeze-gtk;
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

    services = {
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

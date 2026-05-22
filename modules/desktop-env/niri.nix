{
  pkgs,
  currentUser,
  specs,
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
    orca
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
    niri-smart-focus
    kdePackages.qtwayland
  ];

  services.upower.enable = true;

  # Greetd with agreety for niri session login (prompts for password)
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd '${pkgs.niri}/bin/niri-session'";
      };
    };
  };

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

    home.file.".config/niri/outputs.kdl" =
      if currentUser.name == specs.users.pro.name then
        { source = ../../dotfiles/niri/outputs-pro.kdl; }
      else if currentUser.name == specs.users.perso.name then
        { source = ../../dotfiles/niri/outputs-perso.kdl; }
      else if currentUser.name == specs.users.perso-workstation.name then
        { source = ../../dotfiles/niri/outputs-perso-workstation.kdl; }
      else
        builtins.throw "niri: no outputs.kdl defined for user ${currentUser.name}";

    gtk = {
      enable = true;
      gtk4.theme = null;
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
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-animations = true;
        };
        "org/gnome/desktop/default-applications/terminal" = {
          exec = "kitty";
          exec-arg = "-e";
        };
      };
    };

    # Xwayland started via systemd (triggered by graphical-session.target from niri-session)
    systemd.user.services.xwayland-satellite = {
      Unit = {
        Description = "Xwayland outside your Wayland";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
      };
      Service = {
        ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    services.polkit-gnome.enable = true;

    # Polkit authentication agent - starts when niri --session activates graphical-session.target
    # systemd.user.services.polkit-gnome = {
    #   Unit = {
    #     Description = "Polkit GNOME Authentication Agent";
    #     PartOf = [ "graphical-session.target" ];
    #     After = [
    #       "graphical-session.target"
    #       "dbus.socket"
    #     ];
    #   };
    #   Service = {
    #     ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    #     Restart = "on-failure";
    #   };
    #   Install.WantedBy = [ "graphical-session.target" ];
    # };
  };
}

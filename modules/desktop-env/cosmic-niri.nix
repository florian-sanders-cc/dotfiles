{
  currentUser,
  pkgs,
  ...
}:

let
  # Simple derivation: just fetch the session files from GitHub
  cosmic-ext-niri-session = pkgs.stdenv.mkDerivation {
    pname = "cosmic-ext-niri-session";
    version = "unstable-2024-10-11";

    # Fetch the specific files we need directly
    src = pkgs.fetchFromGitHub {
      owner = "Drakulix";
      repo = "cosmic-ext-extra-sessions";
      rev = "66e065728d81eab86171e542dad08fb628c88494";
      hash = "sha256-6JiWdBry63NrnmK3mt9gGSDAcyx/f6L5QsIgZSUakQI=";
    };

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/wayland-sessions

      # Install the startup script (make it executable)
      install -m 755 niri/start-cosmic-ext-niri $out/bin/start-cosmic-ext-niri

      # Install the desktop session file
      install -m 644 niri/cosmic-ext-niri.desktop $out/share/wayland-sessions/cosmic-ext-niri.desktop
    '';

    meta = with pkgs.lib; {
      description = "COSMIC session configuration for Niri compositor";
      homepage = "https://github.com/Drakulix/cosmic-ext-extra-sessions";
      license = pkgs.lib.licenses.gpl3;
      platforms = pkgs.lib.platforms.linux;
    };
  };
in
{
  # Enable the COSMIC login manager
  services.displayManager.cosmic-greeter.enable = true;

  # Configure keyboard layout for COSMIC greeter
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.setxkbmap}/bin/setxkbmap fr
  '';

  # Enable the COSMIC desktop environment
  services.desktopManager.cosmic = {
    enable = true;
  };

  # Enable Niri compositor
  programs.niri.enable = true;

  # Add Niri and related packages to system
  environment.systemPackages = with pkgs; [
    niri
    cosmic-ext-niri-session # Must be in systemPackages for display manager to find the .desktop file
    adwaita-icon-theme
    adw-gtk3
    cliphist
    gtk4
    libadwaita
    nautilus
    orca
    pavucontrol
    polkit_gnome
    seahorse
    noctalia-qs
    niri-smart-focus
    wl-clipboard
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    xwayland-satellite
    gnome-calculator
    gnome-disk-utility
    wireplumber # For wpctl audio control
    kdePackages.qtwayland
  ];

  services.upower.enable = true;

  services.gnome.gnome-keyring.enable = pkgs.lib.mkForce false;

  # XDG Desktop Portal for GNOME app integration
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [
  #     pkgs.xdg-desktop-portal-gtk
  #     pkgs.xdg-desktop-portal-gnome
  #   ];
  # };

  # Home Manager configuration
  home-manager.users."${currentUser.name}" = {
    # Niri configuration (COSMIC-integrated version)
    home.file.".config/niri" = {
      source = ../../dotfiles/niri-cosmic;
      recursive = true;
    };

    # COSMIC shortcuts configuration
    xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom" = {
      source = ../../dotfiles/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom;
    };

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

    # Xwayland started via systemd (triggered by graphical-session.target from COSMIC session)
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

    # Polkit authentication agent
    systemd.user.services.polkit-gnome = {
      Unit = {
        Description = "Polkit GNOME Authentication Agent";
        PartOf = [ "graphical-session.target" ];
        After = [
          "graphical-session.target"
          "dbus.socket"
        ];
      };
      Service = {
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}

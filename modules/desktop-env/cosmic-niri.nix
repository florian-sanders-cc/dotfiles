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
      hash = "sha256-uSkxcYztCVWPwdX1q/JDK1/psUmB5/8zLhYQcDp8Dg4=";
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
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap fr
  '';

  # Enable the COSMIC desktop environment
  services.desktopManager.cosmic = {
    enable = true;
  };

  # Enable Niri compositor
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  # Add Niri and related packages to system
  environment.systemPackages = with pkgs; [
    niri
    cosmic-ext-niri-session  # Must be in systemPackages for display manager to find the .desktop file
    adwaita-icon-theme
    brightnessctl
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
    swww
    niri-smart-focus
    wireplumber  # For wpctl audio control
  ];

  # Enable required services
  security.pam.services = {
    swaylock = { };
  };
  services.upower.enable = true;

  # Home Manager configuration
  home-manager.users."${currentUser.name}" = {
    imports = [
      ../packages/wlogout.nix
    ];

    home.packages = with pkgs; [
      wl-clipboard
      seahorse
    ];

    # Niri configuration (COSMIC-integrated version)
    home.file.".config/niri" = {
      source = ../../dotfiles/niri-cosmic;
      recursive = true;
    };

    # COSMIC shortcuts configuration
    xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom" = {
      source = ../../dotfiles/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom;
    };

    home.sessionVariables = {
      WAYLAND_DISPLAY = "wayland-1";
    };

    # Services configuration
    services.gnome-keyring = {
      enable = true;
      components = [
        "secrets"
        "ssh"
      ];
    };

    # GTK theme configuration
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

    # Dconf settings
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

    # Systemd services for Niri
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

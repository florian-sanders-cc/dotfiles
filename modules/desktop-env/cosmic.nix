{
  currentUser,
  pkgs,
  ...
}:

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

  # Dark theme preference and tiling mode
  home-manager.users."${currentUser.name}" = {
    home.packages = with pkgs; [
      wl-clipboard
      seahorse
    ];

    services.gnome-keyring = {
      enable = true;
      components = [
        "secrets"
        "ssh"
      ];
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };
    };

    xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom" = {
      source = ../../dotfiles/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom;
    };
  };
}

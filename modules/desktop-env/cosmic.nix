{
  currentUser,
  ...
}:

{
  # Enable the COSMIC login manager
  services.displayManager.cosmic-greeter.enable = true;

  # Enable the COSMIC desktop environment
  services.desktopManager.cosmic.enable = true;

  # Dark theme preference
  home-manager.users."${currentUser.name}" = {
    dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };
}

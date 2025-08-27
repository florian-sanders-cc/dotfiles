{ pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./time-i18n.nix
    ./networking.nix
    ./sound.nix
    ./virtualisation.nix
  ];

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
  };

  programs.nix-ld.enable = true;
  # Allow unfree package
  nixpkgs.config.allowUnfree = true;

  # Configure keymap
  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  # Configure console keymap (before display manager kicks in)
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  system.autoUpgrade.enable = false;
  system.autoUpgrade.allowReboot = false;

  # Special rules for HyprX
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="03f0", ATTR{idProduct}=="028c", ATTR{power/control}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="03f0", ATTR{idProduct}=="0294", ATTR{power/control}="-1"
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ wget ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

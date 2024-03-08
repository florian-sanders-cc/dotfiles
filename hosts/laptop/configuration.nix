{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../shared/time-i18n.nix
      ../shared/boot.nix
      ./networking.nix
      ../shared/pkgs.nix
      ../shared/sound-pipewire.nix
      ../shared/user-flo.nix
      ./gpu.nix
      #./nvidia.nix
    ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.blueman.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="03f0", ATTR{idProduct}=="028c", ATTR{power/control}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="03f0", ATTR{idProduct}=="0294", ATTR{power/control}="-1"
  '';

  # Allow unfree package
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  hardware.tuxedo-rs = {
    enable = true;
    tailor-gui.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}


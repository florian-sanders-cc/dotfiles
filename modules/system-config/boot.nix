{
  # SYSTEMD
  boot.loader.systemd-boot.enable = true;
  # GRUB
  # boot.loader.grub = {
  #   enable = true;
  #   device = "nodev";
  # };

  boot.loader.efi.canTouchEfiVariables = true;
}

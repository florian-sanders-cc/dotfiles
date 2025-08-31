{ config
, lib
, pkgs
, modulesPath
, currentUser
, ...
}:

let
  specs = import ../../config-specifications.nix;

in
{
  imports = [
    ./gpu.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = lib.mkIf (currentUser.name == specs.users.perso-workstation.name) {
    nvidia.enable = true;
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    # Kernel parameters to fix DisplayPort EDID detection
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.initrd.systemd.enable = true;

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/fb4ae496-4a29-46f8-b998-22acf24ae355";
      fsType = "ext4";
    };

    boot.initrd.luks.devices."luks-0276fde3-5e5b-4c53-9f43-11a7791bc073".device =
      "/dev/disk/by-uuid/0276fde3-5e5b-4c53-9f43-11a7791bc073";

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/8B79-AEB6";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [ ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.eno1.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.graphics.enable = true;

    # NVIDIA configuration is handled by gpu.nix
    # Remove duplicate videoDrivers and nvidia.open settings
  };
}

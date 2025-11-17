{
  config,
  lib,
  pkgs,
  modulesPath,
  currentUser,
  ...
}:

let
  specs = import ../../config-specifications.nix;

in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = lib.mkIf (currentUser.name == specs.users.perso-workstation.name) {
    nvidia.enable = true;
    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];
    boot.kernelPackages = pkgs.linuxPackages_zen;

    boot.initrd.systemd.enable = true;

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/fcff2378-0e13-4d6a-8682-c24e72cccfc9";
      fsType = "ext4";
    };

    boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/327b948b-f734-45bb-ade5-bc14b2b616b5";

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F00A-70A0";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [
      { device = "/dev/disk/by-uuid/9692c871-7e22-4481-9784-427077e383a9"; }
    ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlp7s0.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}

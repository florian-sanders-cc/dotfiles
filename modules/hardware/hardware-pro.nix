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
    ./gpu.nix
  ];

  config = lib.mkIf (currentUser.name == specs.users.pro.name) {
    intel.enable = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Intel P-state driver for frequency scaling
    boot.kernelParams = [ "intel_pstate=active" ];

    # TLP for automatic power management (AC vs battery)
    services.tlp = {
      enable = true;
      settings = {
        # -- AC Power (performance) --
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_MIN_PERF_ON_AC = 80;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_AC = 1;

        # -- Battery Power (conservative) --
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 80;
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
      };
    };

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # TODO: add keyboard / usb?
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/6fc89f7d-2a42-419b-94b2-5b5ef911f6c2";
      fsType = "ext4";
    };

    boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/e125c490-0118-4bda-b078-e4d6c334b154";

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/41FF-2A42";
      fsType = "vfat";
      options = [
        "umask=0077"
        "defaults"
      ];
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/ac4568f0-3f89-4ade-a012-a8ff3b24471e"; } ];

    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}

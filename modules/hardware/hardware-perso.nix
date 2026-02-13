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
    ./gpu.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = lib.mkIf (currentUser.name == specs.users.perso.name) {
    intel.enable = true;
    nvidia = {
      enable = true;
      prime = {
        enable = true;
      };
    };

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
        CPU_MAX_PERF_ON_BAT = 60;
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
      };
    };

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
    boot.kernelPackages = pkgs.linuxPackages_zen;

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/24f77d45-ced2-421c-bfa8-086f4a4aa793";
      fsType = "ext4";
    };

    boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/359b8a56-3030-4813-87d2-216f268b612a";

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/8C97-4233";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/3abf49bc-70ed-4c84-b36d-dd50a48ed851"; } ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}

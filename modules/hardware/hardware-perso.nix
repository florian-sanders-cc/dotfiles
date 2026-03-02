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

    boot.kernelParams = [
      "intel_idle.max_cstate=1" # C1 allowed, C6/C7 deep sleep blocked
      # intel_pstate=passive removed — HWP active mode distributes RAPL budget per-core
    ];

    # TUXEDO EC driver: required for proper power limit negotiation with the EC.
    # Without it, the EC falls back to a conservative PL1 cap, throttling
    # all cores regardless of load or AC state.
    hardware.tuxedo-drivers.enable = true;

    # i7-13700H: 2.4 GHz base (P-cores), 5.0 GHz boost
    # TLP for automatic power management (AC vs battery)
    services.tlp = {
      enable = true;
      settings = {
        # -- AC Power --
        # powersave governor + performance EPP: lets HWP make per-core decisions
        # while hinting to prioritize speed when RAPL headroom is available
        CPU_SCALING_GOVERNOR_ON_AC = "powersave"; # HWP ignores governor; powersave = let HWP decide
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance"; # EPP: hint to HWP to prioritize speed
        CPU_HWP_DYN_BOOST_ON_AC = 1; # Intel Dynamic Boost with HWP
        CPU_SCALING_MAX_FREQ_ON_AC = 5000000;
        CPU_BOOST_ON_AC = 1;
        # PLATFORM_PROFILE_ON_AC removed — /sys/firmware/acpi/platform_profile is
        # not available on this machine, so the setting was silently ignored
        # CPU_SCALING_MIN_FREQ_ON_AC removed — was exhausting RAPL budget on idle cores

        # -- Battery Power (conservative) --
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
        CPU_SCALING_MIN_FREQ_ON_BAT = 400000;
        CPU_SCALING_MAX_FREQ_ON_BAT = 2400000;
        CPU_BOOST_ON_BAT = 0;
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

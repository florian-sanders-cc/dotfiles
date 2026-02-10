{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = with lib; {
    intel.enable = mkEnableOption "enable intel drivers";
    nvidia = {
      enable = mkEnableOption "enable nvidia drivers";
      prime = {
        enable = mkEnableOption "enable prime support for hybrid gpu systems";
      };
    };
  };

  config = {
    # Disable hardware acceleration to test startup delays
    hardware.graphics = {
      enable = true;
      extraPackages = lib.mkIf (config.intel.enable) [
        pkgs.intel-media-driver # LIBVA_DRIVER_NAME=iHD
        pkgs.vpl-gpu-rt
      ];
    };

    boot.kernelParams = lib.mkIf (config.intel.enable) [
      # Force XE driver instead of i915 for Tiger Lake GPU (device 9a49)
      # XE provides better performance for app startup times
      "i915.force_probe=!9a49"
      "xe.force_probe=*"
      "xe.enable_guc=0" # Disable GuC submission (can cause issues on some hardware)
    ];

    services.xserver.videoDrivers = lib.mkIf (config.nvidia.enable) [ "nvidia" ];

    # Always blacklist nouveau - we either use Intel or NVIDIA proprietary drivers
    # (nouveau wakes up sleeping GPUs, causing 1-2s startup delay for GPU apps)
    boot.blacklistedKernelModules = [ "nouveau" ];

    # GPU driver environment variables
    environment.sessionVariables = lib.mkMerge [
      # Intel systems (laptops): force apps to use Intel GPU
      # This prevents 1-2s startup delay from probing sleeping NVIDIA eGPU/dGPU
      (lib.mkIf (config.intel.enable) {
        LIBVA_DRIVER_NAME = "iHD";
        # 8086 = Intel's PCI vendor ID - works across all Intel systems
        DRI_PRIME = "vendor_id:8086";
      })
      # NVIDIA-only systems (desktop): use NVIDIA
      (lib.mkIf (config.nvidia.enable && !config.intel.enable) {
        LIBVA_DRIVER_NAME = "nvidia";
      })
    ];

    environment.etc = lib.mkIf (config.nvidia.enable) {
      "egl/egl_external_platform.d".source = "/run/opengl-driver/share/egl/egl_external_platform.d/";
    };

    hardware.nvidia = lib.mkIf (config.nvidia.enable) {
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = lib.mkIf (config.nvidia.prime.enable) false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # Try open-source drivers - they handle DisplayPort better than proprietary
      open = true;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      prime = lib.mkIf (config.nvidia.prime.enable) {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        # FIXME: should be configured since it's hardware dependant
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:46:0:0";
      };

    };
  };
}

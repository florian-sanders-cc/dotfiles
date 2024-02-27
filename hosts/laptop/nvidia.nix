{

  # NVIDIA
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true;
  #   extraPackages = with pkgs; [
  #     # trying to fix `WLR_RENDERER=vulkan sway`
  #     vulkan-validation-layers
  #     # https://nixos.wiki/wiki/Accelerated_Video_Playback
  #     intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #     vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #     vaapiVdpau
  #     libvdpau-va-gl
  #   ];
  # };

  # hardware.nvidia = {
  #
  #   # Modesetting is needed for most Wayland compositors
  #   modesetting.enable = true;
  #
  #   # Use the open source version of the kernel module
  #   # Only available on driver 515.43.04+
  #   open = false;
  #
  #   # Enable the nvidia settings menu
  #   nvidiaSettings = true;
  #
  #   # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
  #   powerManagement.enable = false;
  #   # Fine-grained power management. Turns off GPU when not in use.
  #   # Experimental and only works on modern Nvidia GPUs (Turing or newer).
  #   powerManagement.finegrained = false;
  #
  #   # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  #
  #   prime = {
  #     offload = {
  #       enable = true;
  #       enableOffloadCmd = true;
  #     };
  #
  #     nvidiaBusId = "PCI:01:00:0";
  #     intelBusId = "PCI:00:02:0";
  #   };
  # };
  }

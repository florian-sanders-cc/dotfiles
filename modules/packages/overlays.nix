# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.default;

      helix-nightly = inputs.helix-flake.packages.${prev.stdenv.hostPlatform.system}.default;

      noctalia-qs = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;

      tuxedo-control-center = prev.callPackage ./tuxedo-control-center.nix { };

      handy = inputs.handy-flake.packages.${prev.stdenv.hostPlatform.system}.default;

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-ls = prev.callPackage ./stylelint-ls.nix { };

      wc-ls = prev.callPackage ./wc-ls.nix { };

      gh-actions-ls = prev.callPackage ./gh-actions-ls.nix { };

      cem = prev.callPackage ./cem.nix { };

      wallpapers = prev.callPackage ./wallpapers.nix { };

      icons = prev.callPackage ./icons.nix { };

      niri-smart-focus = prev.callPackage ./niri-smart-focus.nix { };

      playwright-cli = prev.callPackage ./playwright-cli.nix { };

      zed-preview = prev.callPackage ./zed-preview.nix { };

      # Enable VA-API hardware video encoding for WebRTC + Vulkan rendering
      # See: https://wiki.archlinux.org/title/Chromium#Hardware_video_acceleration
      google-chrome = prev.google-chrome.override {
        commandLineArgs = [
          "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder,VaapiIgnoreDriverChecks,WebRTCPipeWireCapturer,Vulkan,VulkanFromANGLE"
          "--disable-features=UseChromeOSDirectVideoDecoder"
          "--ignore-gpu-blocklist"
          "--use-angle=gl-egl"
        ];
      };

      ungoogled-chromium = prev.ungoogled-chromium.override {
        commandLineArgs = [
          "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder,VaapiIgnoreDriverChecks,WebRTCPipeWireCapturer,Vulkan,VulkanFromANGLE"
          "--disable-features=UseChromeOSDirectVideoDecoder"
          "--ignore-gpu-blocklist"
          "--use-angle=gl-egl"
        ];
      };

      # Fix cosmic-osd polkit authentication (https://github.com/pop-os/cosmic-osd/issues/170)
      # Point to the SUID-wrapped helper in /run/wrappers/bin/ (set up by security.wrappers)
      cosmic-osd = prev.cosmic-osd.overrideAttrs (old: {
        env = (old.env or { }) // {
          POLKIT_AGENT_HELPER_1 = "/run/wrappers/bin/polkit-agent-helper-1";
        };
      });
    })
  ];
}

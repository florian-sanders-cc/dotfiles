# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.default;

      noctalia-qs = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;

      handy = prev.callPackage ./handy.nix { };

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-ls = prev.callPackage ./stylelint-ls.nix { };

      wc-ls = prev.callPackage ./wc-ls.nix { };

      gh-actions-ls = prev.callPackage ./gh-actions-ls.nix { };

      wallpapers = prev.callPackage ./wallpapers.nix { };

      icons = prev.callPackage ./icons.nix { };

      clever-switch-profile = prev.callPackage ./clever-switch-profile.nix { };

      niri-smart-focus = prev.callPackage ./niri-smart-focus.nix { };

      zed-preview = prev.callPackage ./zed-preview.nix { };

      # Enable VA-API hardware video encoding for WebRTC + Vulkan rendering
      # See: https://wiki.archlinux.org/title/Chromium#Hardware_video_acceleration
      google-chrome = prev.google-chrome.override {
        commandLineArgs = [
          "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder,VaapiIgnoreDriverChecks,WebRTCPipeWireCapturer,Vulkan,VulkanFromANGLE"
          "--disable-features=UseChromeOSDirectVideoDecoder"
          "--ignore-gpu-blocklist"
          "--use-angle=vulkan"
        ];
      };

      ungoogled-chromium = prev.ungoogled-chromium.override {
        commandLineArgs = [
          "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder,VaapiIgnoreDriverChecks,WebRTCPipeWireCapturer,Vulkan,VulkanFromANGLE"
          "--disable-features=UseChromeOSDirectVideoDecoder"
          "--ignore-gpu-blocklist"
          "--use-angle=vulkan"
        ];
      };

      # Fix cosmic-osd polkit authentication (https://github.com/pop-os/cosmic-osd/issues/170)
      # Point to the SUID-wrapped helper in /run/wrappers/bin/ (set up by security.wrappers)
      cosmic-osd = prev.cosmic-osd.overrideAttrs (old: {
        env = (old.env or { }) // {
          POLKIT_AGENT_HELPER_1 = "/run/wrappers/bin/polkit-agent-helper-1";
        };
      });

      warp-terminal-wayland =
        let
          version = "0.2026.02.10.11.37.stable_01";
        in
        (prev.warp-terminal.override { waylandSupport = true; }).overrideAttrs (old: {
          inherit version;
          src = prev.fetchurl {
            url = "https://releases.warp.dev/stable/v${version}/warp-terminal-v${version}-1-x86_64.pkg.tar.zst";
            hash = "sha256-EdGpswzJBC54OczLewxviqLm7RpvW4e9toebTLNXbtI=";
          };
          buildInputs = old.buildInputs ++ [ prev.xz ];
        });
    })
  ];
}

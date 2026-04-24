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

      opencode = prev.opencode.overrideAttrs (finalAttrs: oldAttrs: rec {
        version = "1.14.28";
        src = prev.fetchFromGitHub {
          owner = "anomalyco";
          repo = "opencode";
          tag = "v${version}";
          hash = "sha256-lsyjM6rhSv1HzEd2d/+aGHqrYMARj+TrFrLMGY2X59U=";
        };
        node_modules = oldAttrs.node_modules.overrideAttrs {
          outputHash = "sha256-shMfcEeS4T/gUKILrXmFTnXISg4CcL682YniuaNlb2I=";
        };
      });

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

      warp-terminal-wayland =
        let
          version = "0.2026.04.08.08.36.stable_05";
        in
        (prev.warp-terminal.override { waylandSupport = true; }).overrideAttrs (old: {
          inherit version;
          src = prev.fetchurl {
            url = "https://releases.warp.dev/stable/v${version}/warp-terminal-v${version}-1-x86_64.pkg.tar.zst";
            hash = "sha256-Vt6NPu5u7LMnP8sxpl8p3JZSk3ymFf4PZmNdmiVMCO0=";
          };
          buildInputs = old.buildInputs ++ [ prev.xz ];
        });
    })
  ];
}

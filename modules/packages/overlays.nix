# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.default;

      helix-nightly = inputs.helix-flake.packages.${prev.stdenv.hostPlatform.system}.default;

      noctalia-qs = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;

      tuxedo-control-center = prev.callPackage ./tuxedo-control-center.nix { };

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-ls = prev.callPackage ./stylelint-ls.nix { };

      vscode-eslint = prev.callPackage ./vscode-eslint.nix { };

      # wc-ls = prev.callPackage ./wc-ls.nix { };

      gh-actions-ls = prev.callPackage ./gh-actions-ls.nix { };

      cem = prev.callPackage ./cem.nix { };

      wallpapers = prev.callPackage ./wallpapers.nix { };

      icons = prev.callPackage ./icons.nix { };

      niri-smart-focus = prev.callPackage ./niri-smart-focus.nix { };

      playwright-cli = prev.callPackage ./playwright-cli.nix { };

      zed-preview = prev.callPackage ./zed-preview.nix { };

      pi-handoff = prev.callPackage ./pi-handoff.nix { };

      pi-coding-agent =
      pi-rtk-bash = prev.callPackage ./pi-rtk-bash.nix { };
        let

          base = prev.callPackage ./pi-coding-agent.nix { };
      # rtk 0.43.0's derivation isn't in the binary cache (Hydra never built
        in
      # this hash), so it compiles from source — and its *test* crate fails
        prev.symlinkJoin {
      # under `-D warnings`: FILTERS_TOML and TomlFilterRegistry::load are
          name = "pi-coding-agent-${base.version}";
      # dead code in the test profile (the real binary uses them). Skip the
          paths = [ base ];
      # check phase until upstream fixes the lint; the binary builds fine.
          nativeBuildInputs = [ prev.makeWrapper ];
      rtk = prev.rtk.overrideAttrs (_old: {
          postBuild = ''
        doCheck = false;
            wrapProgram $out/bin/pi \
      });
              --unset DISPLAY \
              --set PI_SKIP_VERSION_CHECK 1
          '';
        };

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
      # cosmic-osd = prev.cosmic-osd.overrideAttrs (old: {
      #   env = (old.env or { }) // {
      #     POLKIT_AGENT_HELPER_1 = "/run/wrappers/bin/polkit-agent-helper-1";
      #   };
      # });

      warp-terminal-wayland =
        let
          version = "0.2026.06.17.09.49.stable_02";
        in
        (prev.warp-terminal.override { waylandSupport = true; }).overrideAttrs (old: {
          inherit version;
          src = prev.fetchurl {
            url = "https://releases.warp.dev/stable/v${version}/warp-terminal-v${version}-1-x86_64.pkg.tar.zst";
            hash = "sha256-U8dX4kC5HHZpJNer3uleKV/JsC8rCQ+06aaSj3xG1dI=";
          };
          buildInputs = old.buildInputs ++ [ prev.xz ];
        });
    })
  ];
}

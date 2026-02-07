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

      # Fix cosmic-osd polkit authentication (https://github.com/pop-os/cosmic-osd/issues/170)
      # polkit 127+ uses socket activation instead of SUID, so we need to set the helper path at build time
      cosmic-osd = prev.cosmic-osd.overrideAttrs (old: {
        env = (old.env or { }) // {
          POLKIT_AGENT_HELPER_1 = "${final.polkit.out}/lib/polkit-1/polkit-agent-helper-1";
        };
      });

      warp-terminal-wayland =
        let
          version = "0.2026.02.04.08.20.stable_03";
        in
        (prev.warp-terminal.override { waylandSupport = true; }).overrideAttrs (old: {
          inherit version;
          src = prev.fetchurl {
            url = "https://releases.warp.dev/stable/v${version}/warp-terminal-v${version}-1-x86_64.pkg.tar.zst";
            hash = "sha256-q2nrl4bI4R2T0ulKcv1HmQjYgu31tbmL22TgA/+J5XM=";
          };
          buildInputs = old.buildInputs ++ [ prev.xz ];
        });
    })
  ];
}

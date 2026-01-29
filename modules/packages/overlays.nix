# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.default;

      noctalia-qs = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;

      handy = inputs.handy.packages.${prev.stdenv.hostPlatform.system}.default;

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-ls = prev.callPackage ./stylelint-ls.nix { };

      wc-ls = prev.callPackage ./wc-ls.nix { };

      gh-actions-ls = prev.callPackage ./gh-actions-ls.nix { };

      wallpapers = prev.callPackage ./wallpapers.nix { };

      icons = prev.callPackage ./icons.nix { };

      clever-switch-profile = prev.callPackage ./clever-switch-profile.nix { };

      niri-smart-focus = prev.callPackage ./niri-smart-focus.nix { };

      zed-preview = prev.callPackage ./zed-preview.nix { };

      warp-terminal-wayland =
        let
          version = "0.2026.01.21.08.14.stable_05";
        in
        (prev.warp-terminal.override { waylandSupport = true; }).overrideAttrs (old: {
          inherit version;
          src = prev.fetchurl {
            url = "https://releases.warp.dev/stable/v${version}/warp-terminal-v${version}-1-x86_64.pkg.tar.zst";
            hash = "sha256-oUB3b6dvGY/5wrUJVaX8pr1hHX8BT2I1dNq7pjO9dlU=";
          };
          buildInputs = old.buildInputs ++ [ prev.xz ];
        });
    })
  ];
}

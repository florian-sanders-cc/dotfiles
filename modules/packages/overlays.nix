# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.default;

      noctalia-qs = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-ls = prev.callPackage ./stylelint-ls.nix { };

      wc-ls = prev.callPackage ./wc-ls.nix { };

      gh-actions-ls = prev.callPackage ./gh-actions-ls.nix { };

      wallpapers = prev.callPackage ./wallpapers.nix { };

      icons = prev.callPackage ./icons.nix { };

      clever-switch-profile = prev.callPackage ./clever-switch-profile.nix { };

      niri-smart-focus = prev.callPackage ./niri-smart-focus.nix { };

      zed-preview = prev.callPackage ./zed-preview.nix { };
    })

  ];
}

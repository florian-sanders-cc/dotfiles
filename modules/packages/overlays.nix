# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # neovim-nightly = inputs.neovim-flake.packages.${prev.system}.default;

      helix-nightly = inputs.helix-flake.packages.${prev.system}.default;

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-lsp = prev.callPackage ./stylelint-lsp.nix { };
    })
  ];
}

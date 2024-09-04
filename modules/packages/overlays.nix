# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # neovim-nightly = inputs.neovim-flake.packages.${prev.system}.default;

      helix-nightly = inputs.helix-flake.packages.${prev.system}.default;

      zed-latest = inputs.zed-flake.packages.${prev.system}.default;

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-lsp = prev.callPackage ./stylelint-lsp.nix { };

      clever-tools = prev.clever-tools.overrideAttrs (_: rec {
        pname = "clever-tools";
        version = "3.8.3";
        src = prev.fetchFromGitHub {
          owner = "CleverCloud";
          repo = "clever-tools";
          rev = "02117066aa77ea2252eb270c4f10e2e140f98bc4";
          hash = "sha256-90khKgGI6Oi0C9HOgaL2TNUoNoJLLsVJucjDB8RaINk=";
        };

        npmDepsHash = "sha256-s4dX6vU8t8LcXM5ksfRF5WHlNdVdgm5hUArFwfcArq4=";
        npmDeps = final.fetchNpmDeps {
          inherit src;
          name = "${pname}-${version}-npm-deps";
          hash = npmDepsHash;
        };
      });
    })
  ];
}

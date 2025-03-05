# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # neovim-nightly = inputs.neovim-flake.packages.${prev.system}.default;

      # helix-nightly = inputs.helix-flake.packages.${prev.system}.default;

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-lsp = prev.callPackage ./stylelint-lsp.nix { };

      wallpapers = prev.callPackage ./wallpapers.nix { };

      clever-switch-profile = prev.callPackage ./clever-switch-profile.nix { };

      # ghostty-nightly = inputs.ghostty-flake.packages.${prev.system}.default;

      # clever-tools = prev.clever-tools.overrideAttrs (_: rec {
      #   pname = "clever-tools";
      #   version = "3.10.1";
      #   src = prev.fetchFromGitHub {
      #     owner = "CleverCloud";
      #     repo = "clever-tools";
      #     rev = version;
      #     hash = "sha256-dMSVw3buj0m2Ixir8rVeCg0PAVqXFBsBEohKfLsYhaI=";
      #   };
      #
      #   npmDepsHash = "sha256-v0nCYRfmcGbePI838Yhb+XvpN4JItQn2D+AHyNoeZLw=";
      #   npmDeps = final.fetchNpmDeps {
      #     inherit src;
      #     name = "${pname}-${version}-npm-deps";
      #     hash = npmDepsHash;
      #   };
      # });

      zed-preview = prev.callPackage ./zed-preview.nix { };
    })

  ];
}

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

      wallpapers = prev.callPackage ./wallpapers.nix { };

      clever-switch-profile = prev.callPackage ./clever-switch-profile.nix { };

      # clever-tools = prev.clever-tools.overrideAttrs (_: rec {
      #   pname = "clever-tools";
      #   version = "3.8.3";
      #   src = prev.fetchFromGitHub {
      #     owner = "CleverCloud";
      #     repo = "clever-tools";
      #     rev = version;
      #     hash = "sha256-70wyu8+Jb9kR5lIucBZG9UWIufMhsgMBMkT2ohGvE50=";
      #   };
      #
      #   npmDepsHash = "sha256-LljwS6Rd/8WnGpxSHwCr87KWLaRR2i7sMdUuuprYiOE=";
      #   npmDeps = final.fetchNpmDeps {
      #     inherit src;
      #     name = "${pname}-${version}-npm-deps";
      #     hash = npmDepsHash;
      #   };
      # });
    })

  ];
}

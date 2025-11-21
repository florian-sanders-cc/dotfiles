# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.stdenv.hostPlatform.system}.default;

      noctalia-qs = inputs.noctalia.packages.${prev.stdenv.hostPlatform.system}.default;

      # helix-nightly = inputs.helix-flake.packages.${prev.stdenv.hostPlatform.system}.default;

      # opencode = prev.opencode.overrideAttrs (oldAttrs: rec {
      #   version = "v0.10.2";
      #   src = prev.fetchFromGitHub {
      #     owner = "sst";
      #     repo = "opencode";
      #     rev = version;
      #     hash = "sha256-pKlw4DPGygEwLuF+s1BDrLn3lnFZIe7HDp6eWmPUItU=";
      #   };
      #
      #   node_modules = oldAttrs.node_modules.overrideAttrs (_: {
      #     outputHash = "sha256-fGf2VldMlxbr9pb3B6zVL+fW1S8bRjefJW+jliTO73A=";
      #   });
      # });
      #
      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-ls = prev.callPackage ./stylelint-ls.nix { };

      wc-ls = prev.callPackage ./wc-ls.nix { };

      gh-actions-ls = prev.callPackage ./gh-actions-ls.nix { };

      wallpapers = prev.callPackage ./wallpapers.nix { };

      icons = prev.callPackage ./icons.nix { };

      clever-switch-profile = prev.callPackage ./clever-switch-profile.nix { };

      niri-smart-focus = prev.callPackage ./niri-smart-focus.nix { };

      # ghostty-nightly = inputs.ghostty-flake.packages.${prev.stdenv.hostPlatform.system}.default;

      # clever-tools = prev.clever-tools.overrideAttrs (_: rec {
      #   pname = "clever-tools";
      #   version = "4.3.0";
      #   src = prev.fetchFromGitHub {
      #     owner = "CleverCloud";
      #     repo = "clever-tools";
      #     rev = version;
      #     hash = "sha256-YC6wfa8bz21LhOH5YIRZ94rLxWl4f1m24jmAAsTvbS0=";
      #   };
      #   npmDepsHash = "sha256-KCaLAlJtLsTpjWR8PQtgFYJg0zX5vtu78DKowjE6ygI=";
      #   npmDeps = final.fetchNpmDeps {
      #     inherit src;
      #     name = "${pname}-${version}-npm-deps";
      #     hash = npmDepsHash;
      #   };
      # });

      zed-preview = prev.callPackage ./zed-preview.nix { };

      # Override snacks-nvim to use specific commit
      vimPlugins = prev.vimPlugins // {
        snacks-nvim = prev.vimPlugins.snacks-nvim.overrideAttrs (oldAttrs: {
          version = "unstable-2025-01-28";
          src = prev.fetchFromGitHub {
            owner = "folke";
            repo = "snacks.nvim";
            rev = "eadb0ca316ee9af078a181ff9517ce54cb048769";
            hash = "sha256-Kr8NbQ4V0ShJktqQDygd6NN6A6szkcVMlTxhQjjs/AE=";
          };
          # Disable checks - too many modules with optional dependencies
          doCheck = false;
        });
      };
    })

  ];
}

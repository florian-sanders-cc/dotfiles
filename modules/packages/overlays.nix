# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;

      noctalia-qs = inputs.noctalia.defaultPackage.${prev.system};

      # helix-nightly = inputs.helix-flake.packages.${prev.system}.default;

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

      copilot-cli = prev.callPackage ./copilot-cli.nix { };

      stylelint-ls = prev.callPackage ./stylelint-ls.nix { };

      wc-ls = prev.callPackage ./wc-ls.nix { };

      wallpapers = prev.callPackage ./wallpapers.nix { };

      clever-switch-profile = prev.callPackage ./clever-switch-profile.nix { };

      niri-smart-focus = prev.callPackage ./niri-smart-focus.nix { };

      # ghostty-nightly = inputs.ghostty-flake.packages.${prev.system}.default;

      clever-tools = prev.clever-tools.overrideAttrs (_: rec {
        pname = "clever-tools";
        version = "4.1.0";
        src = prev.fetchFromGitHub {
          owner = "CleverCloud";
          repo = "clever-tools";
          rev = version;
          hash = "sha256-ntKxMlRBE0WoaO2Fmpymhm7y7kCwe197sotNzpK92C4=";
        };

        nodejs = prev.pkgs.nodejs_22;

        buildPhase = ''
          node scripts/bundle-cjs.js ${version} false
        '';

        installPhase = ''
          mkdir -p $out/bin $out/lib/clever-tools
          cp build/${version}/clever.cjs $out/lib/clever-tools/clever.cjs

          makeWrapper ${nodejs}/bin/node $out/bin/clever \
            --add-flags "$out/lib/clever-tools/clever.cjs" \
            --set NO_UPDATE_NOTIFIER true

          runHook postInstall
        '';

        npmDepsHash = "sha256-GsJlrz41q9GvFpYZcauuGXgMCG6mqSuI5gy+hxlJfUQ=";
        npmDeps = final.fetchNpmDeps {
          inherit src;
          name = "${pname}-${version}-npm-deps";
          hash = npmDepsHash;
        };
      });

      zed-preview = prev.callPackage ./zed-preview.nix { };
    })

  ];
}

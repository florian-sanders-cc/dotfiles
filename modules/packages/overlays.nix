# TODO: should we split into separate files & move random-labels.nix to overlay?
{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # neovim-nightly = inputs.neovim-flake.packages.${prev.system}.default;

      helix-nightly = inputs.helix-flake.packages.${prev.system}.default;

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-lsp = prev.callPackage ./stylelint-lsp.nix { };

      # FIX FOR Helix
      vscode-langservers-extracted = prev.vscode-langservers-extracted.overrideAttrs (old: rec {
        buildPhase =
          let
            extensions = "../resources/app/extensions";
          in
          ''
            npx babel ${extensions}/css-language-features/server/dist/node \
              --out-dir lib/css-language-server/node/
            npx babel ${extensions}/html-language-features/server/dist/node \
              --out-dir lib/html-language-server/node/
            npx babel ${extensions}/json-language-features/server/dist/node \
              --out-dir lib/json-language-server/node/
            cp -r ${prev.vscode-extensions.dbaeumer.vscode-eslint}/share/vscode/extensions/dbaeumer.vscode-eslint/server/out \
              lib/eslint-language-server
          '';
      });
      # vscode-eslint-2-4-2 = prev.callPackage ./vscode-eslint-2-4-2.nix { };
      # vscode-langservers-extracted-4-8-0 = prev.callPackage ./vscode-langservers-extracted-4-8-0.nix {
      #   vscode-eslint = final.vscode-eslint-2-4-2;
      # };

      clamav = prev.clamav.overrideAttrs (old: rec {
        version = "1.4.0";
        src = prev.pkgs.fetchurl {
          url = "https://www.clamav.net/downloads/production/${old.pname}-${version}.tar.gz";
          hash = "sha256-1nqymeXKBdrT2imaXqc9YCCTcqW+zX8TuaM8KQM4pOY=";
        };
      });
    })
  ];
}

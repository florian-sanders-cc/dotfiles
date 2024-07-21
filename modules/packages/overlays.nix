# TODO: should we split into separate files & move random-labels.nix to overlay?
{
  nixpkgs.overlays = [
    (final: prev: {
      # neovim-nightly = inputs.neovim-flake.packages.${prev.system}.default;

      # helix-nightly = inputs.helix-flake.packages.${prev.system}.default;

      clever-tools = prev.clever-tools.overrideAttrs {
        postInstall = final.lib.optionalString (final.stdenv.buildPlatform.canExecute final.stdenv.hostPlatform) ''
          installShellCompletion --cmd clever \
            --bash <($out/bin/clever --bash-autocomplete-script $out/bin/clever) \
            --zsh <($out/bin/clever --zsh-autocomplete-script $out/bin/clever)
        '' + '' 
      rm $out/bin/install-clever-completion
      rm $out/bin/uninstall-clever-completion
    '';
      };

      clamav = prev.clamav.overrideAttrs {
        checkInputs = [
          final.python3.pkgs.pytest
        ];
      };

      random-labels = prev.callPackage ./random-labels.nix { };

      stylelint-lsp = prev.callPackage ./stylelint-lsp.nix { };
    })
  ];
}

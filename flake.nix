{
  inputs = {
    # --- Unstable channels ---
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # --- Stable channels ---
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # home-manager.url = "github:nix-community/home-manager/release-23.11";

    # --- Dev Flakes ---
    # neovim-flake = {
    #   url = "github:neovim/neovim/release-0.10?dir=contrib";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # helix-flake = {
    #   url = "github:helix-editor/helix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      overlays = [
        (final: prev: {
          # neovim-nightly = inputs.neovim-flake.packages.${prev.system}.default;
          # helix-nightly = inputs.helix-flake.packages.${prev.system}.default;
          clever-tools = prev.clever-tools.overrideAttrs {
            postInstall = final.lib.optionalString (final.stdenv.buildPlatform.canExecute final.stdenv.hostPlatform) ''
              installShellCompletion --cmd clever \
                --bash <($out/bin/clever --bash-autocomplete-script $out/bin/clever) \
                --zsh <($out/bin/clever --zsh-autocomplete-script $out/bin/clever)
              rm $out/bin/install-clever-completion
              rm $out/bin/uninstall-clever-completion
            '';
          };
          clamav = prev.clamav.overrideAttrs {
            checkInputs = [
              final.python3.pkgs.pytest
            ];
          };
        })
      ];
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        pro = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import ./modules/common.nix {
              inherit overlays inputs;
              lib = nixpkgs.lib;
              currentUser = "flo-pro";
            })
            ./modules/security.nix
          ];
        };
        # perso = {
        #   inherit system;
        #   modules = [
        #     (import ./modules/common.nix { inherit overlays; })
        #     (import ./modules/home-manager.nix { 
        #       inherit home-manager;
        #       user = "flo-perso";
        #     })
        #     ./modules/security.nix
        #   ];
        # };
      };
    };
}

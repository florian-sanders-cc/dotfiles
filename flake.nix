{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:florian-sanders-cc/nixpkgs/clever-tools";
    home-manager.url = "github:nix-community/home-manager";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # neovim-flake = {
    #   url = "github:neovim/neovim/release-0.10?dir=contrib";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # helix-flake = {
    #   url = "github:helix-editor/helix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      overlays = [
        (final: prev: {
          # neovim-nightly-pkgs = inputs.neovim-flake.packages.${prev.system}.default;
          # helix-editor-pkgs = inputs.helix-flake.packages.${prev.system}.default;
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
    in
    {
      nixosConfigurations = {
        laptop-gnome = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/shared/gnome.nix
            ./hosts/laptop/configuration.nix
            ./hosts/laptop/security.nix
            ./hosts/shared/virtualisation.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = overlays;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.flo = {
                imports = [
                  ./hosts/shared/home.nix
                ];
              };
            }
          ];
        };
        laptop-plasma = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/shared/kde-plasma.nix
            ./hosts/laptop/configuration.nix
            ./hosts/laptop/security.nix
            ./hosts/shared/virtualisation.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = overlays;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.flo = {
                imports = [
                  ./hosts/shared/home.nix
                ];
              };
            }
          ];
        };
        laptop-hypr = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/laptop/configuration.nix
            ./hosts/laptop/security.nix
            ./hosts/shared/virtualisation.nix
            home-manager.nixosModules.home-manager
            { programs.hyprland.enable = true; }
            {
              nixpkgs.overlays = overlays;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.flo = {
                imports = [
                  ./hosts/shared/home.nix
                  ./hosts/shared/hyprland.nix
                ];
              };
            }
          ];
        };
      };
    };
}

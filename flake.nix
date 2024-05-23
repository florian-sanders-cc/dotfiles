{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    clever-tools-flake = {
      url = "github:florian-sanders-cc/clever-tools-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, clever-tools-flake, ... }:
    let
      overlays = [
        (final: prev: {
          # neovim-nightly-pkgs = inputs.neovim-flake.packages.${prev.system}.default;
          # helix-editor-pkgs = inputs.helix-flake.packages.${prev.system}.default;
          clever-tools = inputs.clever-tools-flake.packages.${prev.system}.default;
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

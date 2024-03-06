{
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    # home-manager.url = "github:nix-community/home-manager/release-23.05";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, neovim-flake, ... }:
    let
      overlays = [
        (final: prev: {
          neovim-nightly-pkgs = inputs.neovim-flake.packages.${prev.system}.default;
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
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.flo = { };
            }
          ];
        };
        laptop-hypr = nixpkgs.lib.nixosSystem rec {
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
                ];
              };
            }
          ];
        };
      };
    };
}

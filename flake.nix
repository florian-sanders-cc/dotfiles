{
  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      mkNixosConfig = { user, desktop }: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules
          { inherit user desktop; }
        ];
        specialArgs = { inherit home-manager inputs; };
      };
      specs = import ./config-specifications.nix;

    in
    {
      nixosConfigurations = {
        pro = mkNixosConfig {
          user = specs.users.pro;
          desktop = specs.desktops.plasma;
        };

        perso = mkNixosConfig {
          user = specs.users.perso;
          desktop = specs.desktops.plasma;
        };
      };
    };
  inputs =
    {
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
      helix-flake = {
        url = "github:helix-editor/helix";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      home-manager.inputs.nixpkgs.follows = "nixpkgs";
    };
}

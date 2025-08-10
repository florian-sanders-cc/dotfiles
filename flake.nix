{
  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      mkNixosConfig =
        { user, desktop }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./modules
            { inherit desktop; }
          ];
          specialArgs = {
            inherit home-manager inputs specs;
            currentUser = user;
          };
        };
      specs = import ./config-specifications.nix;

    in
    {
      nixosConfigurations = {
        pro = mkNixosConfig {
          user = specs.users.pro;
          desktop = specs.desktops.niri;
        };

        perso = mkNixosConfig {
          user = specs.users.perso;
          desktop = specs.desktops.niri;
        };

        perso-workstation = mkNixosConfig {
          user = specs.users.perso-workstation;
          desktop = specs.desktops.cosmic;
        };
      };
    };
  inputs = {
    # --- Unstable channels ---
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Stable channels ---
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # home-manager.url = "github:nix-community/home-manager/release-23.11";

    # --- Dev Flakes ---
    # helix-flake = {
    #   url = "github:helix-editor/helix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # ghostty-flake = {
    #   url = "github:ghostty-org/ghostty";
    # };

    # niri = {
    #   url = "github:YaLTeR/niri";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
}

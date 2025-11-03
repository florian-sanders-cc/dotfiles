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
          ];
          specialArgs = {
            inherit home-manager inputs specs;
            currentUser = user;
            currentDesktop = desktop;
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
          desktop = specs.desktops.niri;
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

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell?ref=v2.21.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Stable channels ---
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # home-manager.url = "github:nix-community/home-manager/release-23.11";

    # --- Dev Flakes ---
    helix-flake = {
      url = "github:helix-editor/helix?rev=adfcf4849e25609d13ca8dacb81a4ec782d90b28";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ghostty-flake = {
    #   url = "github:ghostty-org/ghostty";
    # };

    # niri = {
    #   url = "github:YaLTeR/niri";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
}

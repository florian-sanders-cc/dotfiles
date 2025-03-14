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
          desktop = specs.desktops.niri;
        };
      };
    };
  inputs = {
    # --- Unstable channels ---
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:florian-sanders-cc/nixpkgs/clever-tools-3-9-0";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # zed-flake = {
    #   url = "github:zed-industries/zed?rev=1b1c2e55f32d10d351dae213f1c9af26b17cc630";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # ghostty-flake = {
    #   url = "github:ghostty-org/ghostty";
    # };

    # nixos-cosmic = {
    #   url = "github:lilyinstarlight/nixos-cosmic";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # niri = {
    #   url = "github:YaLTeR/niri";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
}

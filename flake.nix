{
  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      lix-module,
      ...
    }:
    let
      system = "x86_64-linux";
      mkNixosConfig =
        { user, desktop }:
        let
          # Determine modules based on user
          extraModules = if user.name == "flo-perso" then [ lix-module.nixosModules.default ] else [ ];
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./modules
            { inherit user desktop; }
          ] ++ extraModules;
          specialArgs = {
            inherit home-manager inputs;
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

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
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

    zed-flake = {
      url = "github:zed-industries/zed?ref=refs/tags/v0.160.7";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

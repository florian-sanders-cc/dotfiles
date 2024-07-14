{ overlays, lib, inputs, currentUser, ... }:
 
{
  imports = [
    { nixpkgs.overlays = overlays; }
    (import ./home-manager.nix { inherit inputs currentUser; })
    ../hosts/shared/configuration.nix
    ./desktop-env.nix
    ../hosts/shared/virtualisation.nix
  ];

  options = {
    currentUser = lib.mkOption {
      type = lib.types.str;
      default = "flo-pro";
      example = true;
      description = "user to create";
    };
  };

  config = {
    inherit currentUser;
  };
}

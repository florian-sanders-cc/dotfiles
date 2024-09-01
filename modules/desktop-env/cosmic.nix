{
  inputs,
  config,
  lib,
  ...
}:

{
  imports = [
    {
      nix.settings = {
        substituters = [ "https://cosmic.cachix.org/" ];
        trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
      };
    }
    inputs.nixos-cosmic.nixosModules.default
  ];

  config = lib.mkIf (config.desktop == "cosmic") {
    services = {
      # displayManager.cosmic-greeter.enable = true;
      xserver.displayManager.gdm.enable = true;
      desktopManager.cosmic.enable = true;
    };
    system.nixos.tags = [ "cosmic" ];
  };
}

{ ... }:

{
  imports = [
    ./hardware
    ./system-config
    ./user
    ./desktop-env
    ./packages
    ./dev-env.nix
    ./security.nix
  ];
}

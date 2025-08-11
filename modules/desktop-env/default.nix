{ lib, currentDesktop, ... }:

let
  configSpecs = import ../../config-specifications.nix;
in

{
  imports = lib.flatten [
    (lib.optional (currentDesktop == configSpecs.desktops.plasma) ./kde-plasma.nix)
    (lib.optional (currentDesktop == configSpecs.desktops.gnome) ./gnome.nix)
    (lib.optional (currentDesktop == configSpecs.desktops.hyprland) ./hyprland.nix)
    (lib.optional (currentDesktop == configSpecs.desktops.cosmic) ./cosmic.nix)
    (lib.optional (currentDesktop == configSpecs.desktops.niri) ./niri.nix)
  ];
}

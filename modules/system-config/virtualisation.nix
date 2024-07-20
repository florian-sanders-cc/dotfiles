{ pkgs, config, ... }:

{
  virtualisation.docker = {
    enable = true;
    # Would be safer but does not work with Distrobox?
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };
  users.users."${config.user.name}".extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    # Emulator
    qemu

    # Simple CLI to manage VM
    quickemu

    # screen & resolution
    spice
    spice-gtk
    spice-vdagent
  ];
}

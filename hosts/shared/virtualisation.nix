{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };
  users.users.flo.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [ qemu quickemu spice spice-gtk spice-vdagent ];
}

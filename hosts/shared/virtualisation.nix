{ pkgs, config, ... }:

{
  virtualisation.docker = {
    enable = true;
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };
  users.users.flo-pro.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [ qemu quickemu spice spice-gtk spice-vdagent ];
}

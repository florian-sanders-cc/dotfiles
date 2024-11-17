{ lib, config, ... }:

{
  options = {
    steam = {
      enable = lib.mkEnableOption "Steam";
    };
  };

  config = {
    programs.steam = lib.mkIf (config.steam.enable) {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };
}

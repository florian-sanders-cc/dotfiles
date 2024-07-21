{ config, ... }:

let
  user = config.user;

in
{
  networking.hostName = "nixos-${user.name}";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.enableIPv6 = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # prometheus-ready exporter
  # services.mtr-exporter.enable = true;
}

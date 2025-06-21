{
  pkgs,
  lib,
  config,
  currentUser,
  ...
}:

let
  specs = import ../config-specifications.nix;

in
{
  # Networking
  networking.firewall.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 6006 80 443 8080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Polkit & rtkit
  security.polkit.enable = true;
  security.rtkit.enable = true;

  # SSH & GPG
  programs.gnupg.agent = {
    enable = true;
  };

  # environment.shellInit = ''
  #   gpg-connect-agent /bye
  #   export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  # '';

  services.openssh = {
    enable = true;
    ports = [ 5432 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ currentUser.name ];
    };
  };

  # ClamAV
  services.clamav.daemon.enable = true;
  services.clamav.daemon.settings = {
    OnAccessExcludeUname = "clamav";
    OnAccessIncludePath = "${currentUser.homeDirectory}/Downloads";
    LogSyslog = true;
    LogTime = true;
    VirusEvent = lib.mkIf (currentUser.name == specs.users.pro.name) "/usr/sbin/clamav-notify-cc.sh";
  };
  services.clamav.updater.enable = true;
  systemd.services.clamav-daemon = {
    path = [
      pkgs.bash
      pkgs.nix
      pkgs.coreutils-full
      pkgs.hostname
      pkgs.curl
    ];
    serviceConfig = pkgs.lib.mkForce {
      ExecStart = "${pkgs.clamav}/bin/clamd";
      ExecReload = "${pkgs.coreutils}/bin/kill -USR2 $MAINPID";
      User = "clamav";
      Group = "clamav";
      StateDirectory = "clamav";
      RuntimeDirectory = "clamav";
      PrivateNetwork = "no";
    };
  };
  systemd.services.clamav-clamonacc = {
    enable = true;
    path = [
      pkgs.nix
      pkgs.bash
    ];
    unitConfig = {
      Description = "ClamAV daemon for on-access scanning";
      Wants = "network-online.target";
      After = "network-online.target syslog.target";
      Requires = "clamav-daemon.service";
    };
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.bash}/bin/bash -c \"while [ ! -S /run/clamav/clamd.ctl ]; do sleep 1; done\"";
      ExecStart = "${pkgs.clamav}/bin/clamonacc --foreground --stream --move=/var/lib/clamav/quarantine";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
  };
}

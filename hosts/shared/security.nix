{ pkgs, ... }:

{
  services.clamav.daemon.enable = true;
  services.clamav.daemon.settings = {
    OnAccessExcludeUname = "clamav";
    OnAccessIncludePath = "~/Downloads";
    VirusEvent = "/usr/sbin/clamav-notify-cc.sh";
  };
  services.clamav.updater.enable = true;
  systemd.services.clamav-freshclam.wants = [ "network-online.target" ];
  systemd.services.clamav-daemon = {
    path = [ pkgs.bash pkgs.nix pkgs.coreutils-full pkgs.hostname pkgs.curl ];
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
    path = [ pkgs.nix pkgs.bash ];
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

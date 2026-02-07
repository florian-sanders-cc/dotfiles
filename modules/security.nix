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

  # SUID wrapper for polkit-agent-helper-1 (needed for password verification via PAM)
  security.wrappers.polkit-agent-helper-1 = {
    owner = "root";
    group = "root";
    setuid = true;
    source = "${pkgs.polkit.out}/lib/polkit-1/polkit-agent-helper-1";
  };

  # Install GnuPG system-wide
  environment.systemPackages = with pkgs; [
    gnupg
  ];

  # PAM configuration for GPG auto-unlock
  security.pam.services.greetd.gnupg.enable = true;
  security.pam.services.cosmic-greeter.gnupg.enable = true;
  security.pam.services.login.gnupg.enable = true;
  security.pam.services.gdm.gnupg = {
    enable = true;
    storeOnly = true; # Only store the password, don't try to unlock yet
  };
  security.pam.services.gdm-password.gnupg = {
    enable = true;
    storeOnly = false; # Actually unlock the keys here
  };

  # GPG Agent configuration (via home-manager for user-level control)
  home-manager.users."${currentUser.name}" = {
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      pinentry.package = pkgs.pinentry-gnome3;
      # Declaratively manage SSH keys (sshcontrol file)
      sshKeys = lib.optionals (currentUser ? gpgAuthKeygrip && currentUser.gpgAuthKeygrip != null) [
        currentUser.gpgAuthKeygrip
      ];
      # Extra configuration for gpg-agent
      extraConfig = ''
        allow-preset-passphrase
        max-cache-ttl 900
        default-cache-ttl 300
      '';
    };

    # Configure GPG keys to unlock at login via PAM
    home.file.".pam-gnupg" = {
      text = lib.concatStringsSep "\n" (
        lib.filter (x: x != null) [
          currentUser.gpgAuthKeygrip
          currentUser.gpgSignKeygrip
        ]
      );
    };
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

  services.osquery = lib.mkIf (currentUser.name == specs.users.pro.name) {
    enable = true;
    flags = {
      flagfile = "/etc/osquery/osquery.flags";
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

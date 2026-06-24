{
  pkgs,
  currentUser,
  ...
}:

{
  virtualisation = {
    containers.enable = false;
    docker = {
      enable = false; # stop running the rootful (host-root) daemon
      rootless = {
        enable = true;
        setSocketVariable = true; # exports DOCKER_HOST to the user's rootless socket
      };
    };

    libvirtd = {
      enable = true;
    };
  };

  programs.virt-manager.enable = true;

  # Enable systemd-nspawn container support + machines target
  systemd.targets.machines.enable = false;

  users.users."${currentUser.name}".extraGroups = [
    "libvirt"
    "kvm"
  ];

  environment.systemPackages = with pkgs; [
    # Emulator
    (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
      qemu-system-x86_64 \
          -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
          "$@"
    '')
    libvirt-glib
    # Simple CLI to manage VM
    quickemu

    # screen & resolution
    spice
    spice-gtk
    spice-vdagent

    dive # look into docker image layers
    # docker-compose # start group of containers for dev
  ];
}

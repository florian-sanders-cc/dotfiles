{ pkgs, config, currentUser, ... }:

{
  virtualisation.docker = {
    enable = true;
    # Would be safer but does not work with Distrobox?
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };

  virtualisation.libvirtd = {
    enable = true;
  };

  programs.virt-manager.enable = true;

  users.users."${currentUser.name}".extraGroups = [ "docker" ];

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
  ];
}

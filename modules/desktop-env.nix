{ ... }:

{
  specialisation = {
    plasma.configuration = {
      imports = [
        ../hosts/shared/kde-plasma.nix
        {
          home-manager.users.flo-pro = {
            xdg.configFile."kglobalshortcutsrc" = {
              source = ../dotfiles/plasma/kglobalshortcutsrc;
            };
            xdg.configFile."kwalletrc" = {
              source = ../dotfiles/plasma/kwalletrc;
            };
          };
        }
      ];
      system.nixos.tags = [ "plasma" ];
    };
    gnome.configuration = {
      imports = [ ../hosts/shared/gnome.nix ];
      system.nixos.tags = [ "gnome" ];
    };
    hypr.configuration = {
      programs.hyprland.enable = true;
      home-manager.users.flo-pro = {
        imports = [
          ../hosts/shared/hyprland.nix
        ];
      };
      system.nixos.tags = [ "hyprland" ];
    };
  };
}


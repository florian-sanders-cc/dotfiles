{ users, desktops, nixpkgs, home-manager, system }:

let
  mkUserDesktopCombination = { user, desktop }: {
    name = "${user.name}/${desktop}";
    value = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./modules
        {
          inherit user desktop;
        }
      ];
      specialArgs = { inherit home-manager; };
    };
  };
  allUserDesktopCombinationsAsList = nixpkgs.lib.lists.flatten
    (map
      (
        user: map
          (
            desktop:
            mkUserDesktopCombination { inherit user desktop; }
          )
          desktops
      )
      users
    );
in
builtins.listToAttrs allUserDesktopCombinationsAsList

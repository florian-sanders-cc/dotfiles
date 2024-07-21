{ configurationSpecs, desktops, nixpkgs, home-manager, system }:

let
  mkUserDesktopCombination = { configurationName, configurationValue, desktop }: {
    name = "${configurationName}-${desktop}";
    value = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ../modules
        { inherit desktop; user = configurationValue.user; }
      ];
      specialArgs = { inherit home-manager configurationName; };
    };
  };
  desktopsAsList = builtins.attrValues desktops;
  configurationsSpecsAsList = builtins.mapAttrs
    (
      configurationName:
      configurationValue:
      (
        map
          (
            desktop:
            mkUserDesktopCombination { inherit configurationName configurationValue desktop; }
          )
          desktopsAsList
      )
    )
    configurationSpecs;

  # allUserDesktopCombinationsAsList = map (configurationName: mkUserDesktopsCombinations {
  #   inherit configurationName desktops;
  # }) configurationNames;
  # mkUserDesktopsCombinations = { configurationName, desktops }: map (desktop: mkUserDesktopCombination {
  #   inherit configurationName desktop; user = getUser { configurationName }; })
  # allUserDesktopCombinationsAsList = nixpkgs.lib.lists.flatten
  #   (map
  #     (
  #       user: map
  #         (
  #           desktop:
  #           mkUserDesktopCombination { inherit user desktop; }
  #         )
  #         desktops
  #     )
  #     users
  #   );
in
builtins.listToAttrs (builtins.concatLists (builtins.attrValues configurationsSpecsAsList))

# pour chaque configName
# pour chaque desktop
#   - 
# je construis un { name = configName; }

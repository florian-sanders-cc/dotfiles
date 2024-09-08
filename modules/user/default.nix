{
  pkgs,
  config,
  home-manager,
  ...
}:

let
  lib = pkgs.lib;
  user = config.user;
  shellAliases = import ./shell-aliases.nix { homeDirectory = user.homeDirectory; };
  specs = import ../../config-specifications.nix;

in
{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users."${user.name}" = rec {

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "${user.name}";
    home.homeDirectory = user.homeDirectory;
    home.shellAliases = lib.mkMerge [
      shellAliases.commonAliases
      (lib.mkIf (user.name == specs.users.pro.name) shellAliases.proAliases)
      (lib.mkIf (user.name == specs.users.perso.name) shellAliases.persoAliases)
    ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "23.11";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.sessionVariables = {
      NPM_PREFIX = "${home.homeDirectory}/.npm-packages";
      PATH = "${home.homeDirectory}/.npm-packages/bin:$PATH";
      NIXOS_OZONE_WL = "1";
    };
  };

  users.defaultUserShell = pkgs.zsh;

  users.users."${user.name}" = {
    isNormalUser = true;
    description = "flo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
    shell = pkgs.fish;
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;
}

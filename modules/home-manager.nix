{ inputs, currentUser, ... }:

let
  homeDirectory = "/home/${currentUser}";
  proAliases = {
    upd-gnome = "sudo nix flake update '${homeDirectory}/.config/nixos-config/' && sudo nixos-rebuild switch --specialisation gnome --upgrade --flake '${homeDirectory}/.config/nixos-config#pro'";
    upd-plasma = "sudo nix flake update '${homeDirectory}/.config/nixos-config/' && sudo nixos-rebuild switch --specialisation plasma --upgrade --flake '${homeDirectory}/.config/nixos-config#pro'";
    upd-hypr = "sudo nix flake update '${homeDirectory}/.config/nixos-config' && sudo nixos-rebuild switch --specialisation hypr --upgrade --flake '${homeDirectory}/.config/nixos-config#pro'";
    SN = "s3cmd -c ${homeDirectory}/s3cfgs/flo-clever.s3cfg sync --delete-removed ${homeDirectory}/Notes/ s3://flo-clever-notes";
    SP = "s3cmd -c ${homeDirectory}/s3cfgs/flo-clever.s3cfg sync --delete-removed --exclude-from ${homeDirectory}/Projects/.s3ignore ${homeDirectory}/Projects s3://flo-projects-backup";
    rt = "random-labels Hubert Mathieu Florian Bob Pierre Hélène --clipboard";
    clever-dev = "${homeDirectory}/Projects/clever-tools/bin/clever.js";
    clever-switch-account = "mv ${homeDirectory}/.config/clever-cloud/clever-tools.json ${homeDirectory}/.config/clever-cloud/clever-tools-tmp.json && mv ${homeDirectory}/.config/clever-cloud/clever-tools-alternative-account.json ${homeDirectory}/.config/clever-cloud/clever-tools.json && mv ${homeDirectory}/.config/clever-cloud/clever-tools-tmp.json ${homeDirectory}/.config/clever-cloud/clever-tools-alternative-account.json && clever profile";
  };
  persoAliases = {
    upd-gnome = "sudo nix flake update '${homeDirectory}/.config/nixos-config/' && sudo nixos-rebuild switch --upgrade --flake '${homeDirectory}/.config/nixos-config#gnome --specialisation perso'";
    upd-plasma = "sudo nix flake update '${homeDirectory}/.config/nixos-config/' && sudo nixos-rebuild switch --upgrade --flake '${homeDirectory}/.config/nixos-config#plasma --specialisation perso'";
    upd-hypr = "sudo nix flake update '${homeDirectory}/.config/nixos-config' && sudo nixos-rebuild switch --upgrade --flake '${homeDirectory}/.config/nixos-config#hypr --specialisation perso'";
  };
  commonAliases = {
    ll = "ls -l -a";
    nn = "cd ${homeDirectory}/Notes";
    clean = "sudo nix-collect-garbage -d && nix-collect-garbage";
    nxcfg = "cd ${homeDirectory}/.config/nixos-config";
    ww = "cd ${homeDirectory}/Projects/";
    setnode = "cat ${homeDirectory}/.config/nixos-config/node-shell/.envrc-example >> .envrc && direnv allow";
  };
  home-manager = inputs.home-manager;
  lib = inputs.nixpkgs.lib;

in
{
  imports = [
    home-manager.nixosModules.home-manager
    {
      home-manager.backupFileExtension = "backup";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users."${currentUser}" = rec {

        # Home Manager needs a bit of information about you and the
        # paths it should manage.
        home.username = "${currentUser}";
        home.homeDirectory = homeDirectory;
        home.shellAliases = lib.mkMerge [
          commonAliases
          (lib.mkIf (currentUser == "flo-pro") proAliases)
          (lib.mkIf (currentUser == "flo-perso") persoAliases)
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

        imports = [
          ../hosts/shared/programs/git.nix
          ../hosts/shared/programs/alacritty.nix
          ../hosts/shared/programs/fzf.nix
          ../hosts/shared/programs/starship.nix
          ../hosts/shared/programs/direnv.nix
          ../hosts/shared/programs/vscode.nix
          ../hosts/shared/programs/zsh.nix
          ../hosts/shared/programs/neovim.nix
          ../hosts/shared/programs/helix.nix
        ];

        home.sessionVariables = {
          NPM_PREFIX = "${home.homeDirectory}/.npm-packages";
          PATH = "${home.homeDirectory}/.npm-packages/bin:$PATH";
          NIXOS_OZONE_WL = "1";
        };
      };
    }
  ];
}

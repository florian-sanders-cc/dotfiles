{ currentUser, pkgs, ... }:

let
  lib = pkgs.lib;
  shellAliases = import ../user/shell-aliases.nix { homeDirectory = currentUser.homeDirectory; };
  specs = import ../../config-specifications.nix;

in
{
  programs = {
    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };

    direnv = {
      enable = true;
      enableNushellIntegration = true;
    };

    nushell = {
      enable = true;

      # shellAliases = lib.mkMerge [
      #   shellAliases.commonAliases
      #   (lib.mkIf (currentUser.name == specs.users.pro.name) shellAliases.proAliases)
      #   (lib.mkIf (currentUser.name == specs.users.perso.name) shellAliases.persoAliases)
      #   (lib.mkIf (
      #     currentUser.name == specs.users.perso-workstation.name
      #   ) shellAliases.persoWorkstationAliases)
      # ];

      extraConfig = ''
        let carapace_completer = {|spans|
          carapace $spans.0 nushell ...$spans | from json
         }
        $env.config = {
          show_banner: false
          completions: {
            case_sensitive: false # case-sensitive completions
            quick: true    # set to false to prevent auto-selecting completions
            partial: true    # set to false to prevent partial filling of the prompt
            algorithm: "fuzzy"    # prefix or fuzzy
            external: {
              # set to false to prevent nushell looking into $env.PATH to find more suggestions
              enable: true 
              # set to lower can improve completion performance at the cost of omitting some options
              max_results: 100 
              completer: $carapace_completer # check 'carapace_completer' 
            }
          }
        }

        alias SN = s3cmd -c /home/flo-pro/s3cfgs/flo-clever.s3cfg sync --delete-removed /home/flo-pro/Notes/ s3://flo-clever-notes
        alias SP = s3cmd -c /home/flo-pro/s3cfgs/flo-clever.s3cfg sync --delete-removed --exclude-from /home/flo-pro/Projects/.s3ignore /home/flo-pro/Projects s3://flo-projects-backup
        alias ccdev = clever-switch-profile user_e37814b0-954c-4e16-9a53-544b0f7cf58d
        alias ccprod = clever-switch-profile user_e320e720-7c5c-4f7e-b9f0-0a598abe106c
        alias clean = do { sudo nix-collect-garbage --delete-older-than 7d } and { nix-collect-garbage --delete-older-than 7d }
        alias clever-dev = /home/flo-pro/Projects/clever-tools/bin/clever.js
        alias ll = ls -l -a
        alias nn = cd /home/flo-pro/Notes
        alias nxcfg = cd /home/flo-pro/.config/nixos-config
        alias rebuild-pro = nixos-rebuild switch --flake '/home/flo-pro/.config/nixos-config#pro' --sudo
        alias rt = random-labels Hubert Mathieu Florian Bob Pierre Hélène Clara Marion --clipboard
        alias setnode = do { cat /home/flo-pro/.config/nixos-config/node-shell/.envrc-example >> .envrc } and { direnv allow }
        alias upd-pro = do { nix flake update --flake '/home/flo-pro/.config/nixos-config' } and { nixos-rebuild switch --upgrade --flake '/home/flo-pro/.config/nixos-config#pro' --sudo }
        alias ww = cd /home/flo-pro/Projects/

        def start_zellij [] {
          if 'ZELLIJ' not-in ($env | columns) {
            if 'ZELLIJ_AUTO_ATTACH' in ($env | columns) and $env.ZELLIJ_AUTO_ATTACH == 'true' {
              zellij attach -c
            } else {
              zellij
            }

            if 'ZELLIJ_AUTO_EXIT' in ($env | columns) and $env.ZELLIJ_AUTO_EXIT == 'true' {
              exit
            }
          }
        }

        if (
          ($env.TERM == "alacritty" or $env.TERM == "foot")
        ) {
          start_zellij
        }

        def --env y [...args] {
            let tmp = (mktemp -t "yazi-cwd.XXXXXX")
            yazi ...$args --cwd-file $tmp
            let cwd = (open $tmp)
            if $cwd != "" and $cwd != $env.PWD {
                cd $cwd
            }
            rm -fp $tmp
        }

        overlay use /home/flo-pro/.config/nushell/git-aliases.nu
      '';
    };
  };

  xdg.configFile."nushell" = {
    source = ../../dotfiles/nushell;
    recursive = true;
  };
}

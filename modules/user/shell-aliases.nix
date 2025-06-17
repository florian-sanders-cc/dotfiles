{ homeDirectory }:

let
  nixosConfigPath = "${homeDirectory}/.config/nixos-config";

in
{
  # TODO: use function to generate update / rebuild aliases from user specs
  proAliases = {
    clever-dev = "${homeDirectory}/Projects/clever-tools/bin/clever.js";
    rt = "random-labels Hubert Mathieu Florian Bob Pierre Hélène Clara Marion --clipboard";
    SN = "s3cmd -c ${homeDirectory}/s3cfgs/flo-clever.s3cfg sync --delete-removed ${homeDirectory}/Notes/ s3://flo-clever-notes";
    SP = "s3cmd -c ${homeDirectory}/s3cfgs/flo-clever.s3cfg sync --delete-removed --exclude-from ${homeDirectory}/Projects/.s3ignore ${homeDirectory}/Projects s3://flo-projects-backup";
    upd-pro = "nix flake update --flake '${nixosConfigPath}'; nixos-rebuild switch --upgrade --flake '${nixosConfigPath}#pro' --sudo";
    rebuild-pro = "nixos-rebuild switch --flake '${nixosConfigPath}#pro' --sudo";
    ccprod = "clever-switch-profile user_e320e720-7c5c-4f7e-b9f0-0a598abe106c";
    ccdev = "clever-switch-profile user_e37814b0-954c-4e16-9a53-544b0f7cf58d";
  };
  persoAliases = {
    upd-perso = "nix flake update --flake '${nixosConfigPath}'; nixos-rebuild switch --upgrade --flake '${nixosConfigPath}#perso' --sudo";
    rebuild-perso = "nixos-rebuild switch --flake '${nixosConfigPath}#perso' --sudo";
  };
  persoWorkstationAliases = {
    upd-perso-workstation = "nix flake update --flake '${nixosConfigPath}'; nixos-rebuild switch --upgrade --flake '${nixosConfigPath}#perso-workstation' --sudo";
    rebuild-perso-workstation = "nixos-rebuild switch --flake '${nixosConfigPath}#perso-workstation' --sudo";
  };
  commonAliases = {
    ll = "ls -l -a";
    nn = "cd ${homeDirectory}/Notes";
    clean = "sudo nix-collect-garbage -d; nix-collect-garbage";
    nxcfg = "cd ${homeDirectory}/.config/nixos-config";
    ww = "cd ${homeDirectory}/Projects/";
    setnode = "cat ${homeDirectory}/.config/nixos-config/node-shell/.envrc-example >> .envrc; direnv allow";
  };
}

{ homeDirectory }:

let
  nixosConfigPath = "${homeDirectory}/.config/nixos-config";

in
{
  # TODO: use function to generate update / rebuild aliases from user specs
  proAliases = {
    clever-dev = "${homeDirectory}/Projects/clever-tools/bin/clever.js";
    clever-switch-account = "mv ${homeDirectory}/.config/clever-cloud/clever-tools.json ${homeDirectory}/.config/clever-cloud/clever-tools-tmp.json && mv ${homeDirectory}/.config/clever-cloud/clever-tools-alternative-account.json ${homeDirectory}/.config/clever-cloud/clever-tools.json && mv ${homeDirectory}/.config/clever-cloud/clever-tools-tmp.json ${homeDirectory}/.config/clever-cloud/clever-tools-alternative-account.json && clever profile";
    rt = "random-labels Hubert Mathieu Florian Bob Pierre Hélène --clipboard";
    SN = "s3cmd -c ${homeDirectory}/s3cfgs/flo-clever.s3cfg sync --delete-removed ${homeDirectory}/Notes/ s3://flo-clever-notes";
    SP = "s3cmd -c ${homeDirectory}/s3cfgs/flo-clever.s3cfg sync --delete-removed --exclude-from ${homeDirectory}/Projects/.s3ignore ${homeDirectory}/Projects s3://flo-projects-backup";
    upd-pro = "sudo nix flake update '${nixosConfigPath}' && sudo nixos-rebuild switch --upgrade --flake '${nixosConfigPath}#pro'";
    rebuild-pro = "sudo nixos-rebuild switch --flake '${nixosConfigPath}#pro'";
  };
  persoAliases = {
    upd-perso = "sudo nix flake update '${nixosConfigPath}' && sudo nixos-rebuild switch --upgrade --flake '${nixosConfigPath}#perso'";
    rebuild-perso = "sudo nixos-rebuild switch --flake '${nixosConfigPath}#perso'";
  };
  commonAliases = {
    ll = "ls -l -a";
    nn = "cd ${homeDirectory}/Notes";
    clean = "sudo nix-collect-garbage -d && nix-collect-garbage";
    nxcfg = "cd ${homeDirectory}/.config/nixos-config";
    ww = "cd ${homeDirectory}/Projects/";
    setnode = "cat ${homeDirectory}/.config/nixos-config/node-shell/.envrc-example >> .envrc && direnv allow";
  };
}

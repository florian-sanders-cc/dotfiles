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
    upd-pro = "nix flake update --flake '${nixosConfigPath}'; run0 nixos-rebuild switch --flake '${nixosConfigPath}#pro'";
    rebuild-pro = "run0 nixos-rebuild switch --flake '${nixosConfigPath}#pro'";
    ccprod = "clever profile switch -a prod";
    ccdev = "clever profile switch -a dev";
  };
  persoAliases = {
    upd-perso = "nix flake update --flake '${nixosConfigPath}'; run0 nixos-rebuild switch --flake '${nixosConfigPath}#perso'";
    rebuild-perso = "run0 nixos-rebuild switch --flake '${nixosConfigPath}#perso'";
  };
  persoWorkstationAliases = {
    upd-perso-workstation = "nix flake update --flake '${nixosConfigPath}'; run0 nixos-rebuild switch --flake '${nixosConfigPath}#perso-workstation'";
    rebuild-perso-workstation = "run0 nixos-rebuild switch --flake '${nixosConfigPath}#perso-workstation'";
  };
  commonAliases = {
    ll = "ls -l -a";
    nn = "cd ${homeDirectory}/Notes";
    clean = "run0 nix-collect-garbage --delete-older-than 7d; nix-collect-garbage --delete-older-than 7d";
    nxcfg = "cd ${homeDirectory}/.config/nixos-config";
    ww = "cd ${homeDirectory}/Projects/";
    setnode = "echo 'use flake ~/.config/nixos-config/node-shell' >> .envrc; direnv allow";
    # OpenCode commit helpers
    gcm = "opencode run --agent commit-msg 'Analyze the current git diff and generate a commit message'";
    gcs = "opencode --agent smart-commit --prompt 'Analyze my current changes and help me create atomic commits'";
    # Power management
    pstatus = "tlp-stat -s";
  };
}

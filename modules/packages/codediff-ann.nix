{ pkgs, ... }:

let
  # TypeScript CLI, runs via Node 24+ native type-stripping. No build step.
  script = ../../dotfiles/bin/codediff-ann.ts;
  node = "${pkgs.nodejs}/bin/node";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "codediff-ann" ''exec ${node} ${script} "$@"'')
  ];
}
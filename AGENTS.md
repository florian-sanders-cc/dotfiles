# AGENTS.md

## Rebuild / Update Policy

Never run rebuild or update commands yourself. The user handles all rebuilds and updates.

Do NOT run any of:
- `nixos-rebuild` (build, switch, test, boot, etc.)
- `nix build` / `nixos-build`
- `nh` (os, build, switch, test)
- `nix flake update` / `nix flake lock --update-all`
- `git pull` / system updates of any kind

When changes are made, leave the system un-rebuilt. Report what was changed and let the user rebuild and update manually.
{
  config,
  currentUser,
  ...
}:

let
  nonoDotfiles = "${currentUser.homeDirectory}/.config/nixos-config/dotfiles/nono";
in
{
  home.file = {
    # nono sandbox profiles used by the pi-plan / pi-write fish functions
    # (whole-subtree symlink, idiomatic like agents.nix does for skills).
    ".config/nono/profiles".source =
      config.lib.file.mkOutOfStoreSymlink "${nonoDotfiles}/profiles";

    # nono-owned fish autoload functions — wired PER-FILE (not whole-dir) so
    # nono doesn't "own" ~/.config/fish/functions/, leaving future non-nono
    # fish functions free to live elsewhere. Mirrors how clever.fish
    # completions are wired in fish.nix. fish auto-loads these by name on
    # first call — no interactiveShellInit sourcing, no nixos-rebuild to
    # tweak a comment in a frozen herestring.
    ".config/fish/functions/_nono_playwright_setup.fish".source =
      config.lib.file.mkOutOfStoreSymlink "${nonoDotfiles}/functions/_nono_playwright_setup.fish";
    ".config/fish/functions/_nono_sandbox_env.fish".source =
      config.lib.file.mkOutOfStoreSymlink "${nonoDotfiles}/functions/_nono_sandbox_env.fish";
    ".config/fish/functions/pi-plan.fish".source =
      config.lib.file.mkOutOfStoreSymlink "${nonoDotfiles}/functions/pi-plan.fish";
    ".config/fish/functions/pi-write.fish".source =
      config.lib.file.mkOutOfStoreSymlink "${nonoDotfiles}/functions/pi-write.fish";
    ".config/fish/functions/repo-audit.fish".source =
      config.lib.file.mkOutOfStoreSymlink "${nonoDotfiles}/functions/repo-audit.fish";
  };
}
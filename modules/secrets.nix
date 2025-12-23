{
  pkgs,
  currentUser,
  ...
}:

let
  # Separate GPG home for SOPS (zero cache for security)
  sopsGnupgHome = "${currentUser.homeDirectory}/.gnupg-sops";

in
{
  # Home-manager configuration for SOPS GPG setup
  home-manager.users."${currentUser.name}" = {
    # Create ~/.gnupg-sops directory and config (declaratively managed)
    home.file.".gnupg-sops/gpg-agent.conf" = {
      text = ''
        ## SOPS-specific GPG agent configuration
        ## Zero cache = password required EVERY time (security)

        default-cache-ttl 0
        max-cache-ttl 0

        # Pinentry path resolved by Nix (reproducible across updates)
        pinentry-program ${pkgs.pinentry-gnome3}/bin/pinentry
      '';
    };

    programs.fish.functions = {
      # SOPS wrapper (always uses zero-cache GPG home)
      sops = {
        description = "SOPS with dedicated GPG key (always prompts for password)";
        body = ''
          env GNUPGHOME=${sopsGnupgHome} ${pkgs.sops}/bin/sops $argv
        '';
      };

      # Run command with decrypted secrets (auto-cleanup on exit)
      with-secrets = {
        description = "Run command with decrypted secrets (cleaned up on exit)";
        body = ''
          argparse -n with-secrets h/help p/project -- $argv
          or return

          if set -ql _flag_h; or test (count $argv) -eq 0
              echo "Usage: with-secrets -p <secrets-file> <command...>"
              echo ""
              echo "Options:"
              echo "  -p, --project  path to the encrypted secrets file (required)"
              echo "  -h, --help     Show this help"
              return 0
          end

          if not set -ql _flag_p
              echo "Error: -p/--project flag required" >&2
              echo "Run 'with-secrets --help' for usage" >&2
              return 1
          end

          if test (count $argv) -lt 2
              echo "Error: command to run with secrets required" >&2
              echo "Run 'with-secrets --help' for usage" >&2
              return 1
          end

          for line in (sops -d --output-type dotenv $argv[1])
              set -l parts (string split -m 1 '=' $line)
              set -l key $parts[1]
              set -l value $parts[2]
              set -x $key $value
              echo "Loaded $key to env"
          end
          echo "Running $argv[2..-1] with secrets..."
          eval $argv[2..-1]
        '';
      };
    };
  };
}

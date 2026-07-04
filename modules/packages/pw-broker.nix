{
  pkgs,
  currentUser,
  ...
}:

let
  # Nix path interpolation = immutable /nix/store copies. This is a deliberate
  # departure from the out-of-store-symlink convention used elsewhere: the
  # daemon runs UNSANDBOXED with docker access, so the running copy must not be
  # editable by a sandboxed agent. dotfiles/pw-broker/ is outside every nono
  # grant, and even if an agent gets write there (pi-write launched inside this
  # repo), the edit only takes effect after a human rebuild — visible in git.
  broker = ../../dotfiles/pw-broker/pw-broker.mts;
  client = ../../dotfiles/pw-broker/pw-test.mts;
  node = "${pkgs.nodejs}/bin/node";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "pw-broker" ''exec ${node} ${broker} "$@"'')
    # pw-test is what sandboxed agents call; store paths are readable in the
    # sandbox via nono's built-in nix_runtime group.
    (pkgs.writeShellScriptBin "pw-test" ''exec ${node} ${client} "$@"'')
  ];

  systemd.user.services.pw-broker = {
    Unit = {
      Description = "Playwright test broker (docker runner for sandboxed agents)";
      # rootless docker is a USER unit, also named docker.service
      After = [ "docker.service" ];
      Wants = [ "docker.service" ];
    };
    Service = {
      ExecStart = "${node} ${broker} daemon";
      Restart = "on-failure";
      RestartSec = 2;
      Environment = [
        # virtualisation.docker.rootless.setSocketVariable only reaches login
        # shells, not the systemd user manager (%t = $XDG_RUNTIME_DIR)
        "DOCKER_HOST=unix://%t/docker.sock"
        # the user-manager PATH lacks the system profile, where docker lives
        "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/${currentUser.name}/bin"
      ];
    };
    Install.WantedBy = [ "default.target" ];
  };
}

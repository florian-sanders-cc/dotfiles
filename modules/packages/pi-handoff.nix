{
  lib,
  bash,
  runCommand,
}:

# Trivial derivation: generate the pi-handoff shell script into $out/bin.
# runCommand already sets dontUnpack=true and runs fixupPhase (patchShebangs),
# so the `#!/usr/bin/env bash` shebang is rewritten to the store bash and
# bash ends up on the runtime PATH via fixupPhase — no manual installPhase
# or substituteInPlace needed.
runCommand "pi-handoff"
  {
    buildInputs = [ bash ];
    meta = with lib; {
      description = "Copy last pi response → exit pi → launch pi-write in the same shell";
      platforms = platforms.linux;
    };
  }
  ''
    mkdir -p $out/bin
    cat > $out/bin/pi-handoff << 'PI_HANDOFF_EOF'
#!/usr/bin/env bash
# pi-handoff: copy the last pi response, exit pi+nono, launch pi-write in the
# same shell. The user pastes the clipboard into pi-write's prompt manually.
#
# Triggered by a kitty keybind via:
#   launch --type=background --allow-remote-control pi-handoff @active-kitty-window-id
# Arg $1 = kitty window id (from the @active-kitty-window-id placeholder).
set -euo pipefail

WINDOW_ID="''${1:?usage: pi-handoff <kitty-window-id>}"
target="id:''${WINDOW_ID}"
pre_delay="''${PI_HANDOFF_PRE_DELAY:-0.4}"    # wait for wl-copy to settle
exit_delay="''${PI_HANDOFF_EXIT_DELAY:-1.2}"  # wait for nono teardown

# 1. alt+y -> copy-last-response extension puts the last assistant message
#    on the system clipboard via wl-copy.
kitty @ send-key --match "$target" alt+y
sleep "$pre_delay"

# 2. ctrl+d -> pi exits; nono follows; the fish prompt reappears.
kitty @ send-key --match "$target" ctrl+d
sleep "$exit_delay"

# 3. Launch pi-write in the same shell. The user pastes the clipboard
#    into pi-write's prompt manually (ctrl+shift+v).
kitty @ send-text --match "$target" $'\npi-write\n'
PI_HANDOFF_EOF

    chmod +x $out/bin/pi-handoff
  ''
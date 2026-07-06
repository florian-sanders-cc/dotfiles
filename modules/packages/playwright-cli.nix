{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  playwright-driver,
  jq,
}:

buildNpmPackage rec {
  pname = "playwright-cli";
  version = "0.1.15";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "74d9bf144a96770b6295ceedecb07a2fd7e86775";
    hash = "sha256-M0NZ7h1kSIsxktMWe5n75LDc+MHZvSq6b+iRx6opakU=";
  };

  npmDepsHash = "sha256-ZrO8yIqMYMQUlsQraejVgKRZ7klC5/8UsV3/H1EqYtA=";

  nativeBuildInputs = [
    makeWrapper
    jq
  ];

  dontNpmBuild = true;

  postInstall = ''
    # Locate the bundled playwright-core's browsers.json
    BUNDLED_JSON="$(find $out -path '*/playwright-core/browsers.json' -print -quit)"

    # Create compat browsers directory with nixpkgs browsers and revision symlinks
    COMPAT_DIR="$out/share/playwright-cli/browsers"
    mkdir -p "$COMPAT_DIR"
    ln -sfn ${playwright-driver.browsers}/* "$COMPAT_DIR/"

    # Create compat symlinks for any mismatched revisions between
    # the bundled playwright-core and nixpkgs' playwright-driver
    NIX_JSON="${playwright-driver}/browsers.json"
    for name in chromium chromium-headless-shell firefox webkit ffmpeg; do
      bundled_rev=$(jq -r --arg n "$name" '.browsers[] | select(.name==$n).revision' "$BUNDLED_JSON" 2>/dev/null)
      nix_rev=$(jq -r --arg n "$name" '.browsers[] | select(.name==$n).revision' "$NIX_JSON")
      if [ -n "$bundled_rev" ] && [ -n "$nix_rev" ] && [ "$bundled_rev" != "$nix_rev" ]; then
        dir_name=$(echo "$name" | tr '-' '_')
        if [ -e "$COMPAT_DIR/$dir_name-$nix_rev" ]; then
          ln -sfn "$dir_name-$nix_rev" "$COMPAT_DIR/$dir_name-$bundled_rev"
        fi
      fi
    done

    wrapProgram $out/bin/playwright-cli \
      --set PLAYWRIGHT_BROWSERS_PATH "$COMPAT_DIR" \
      --set PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD "1" \
      --set PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS "true" \
      --set-default PLAYWRIGHT_MCP_CONFIG "$out/share/playwright-cli/default-config.json"

    # Default config: browserName=chromium. Without this, playwright-cli's
    # validateBrowserConfig (coreBundle.js:65678) defaults launchOptions.channel
    # to "chrome" (Google Chrome at /opt/google/chrome/chrome), which is not
    # installed here -> "Chromium distribution 'chrome' is not found". Setting
    # browserName=chromium makes it use the bundled chrome-for-testing/chromium.
    # Used via --set-default above so an explicitly-set PLAYWRIGHT_MCP_CONFIG
    # (e.g. the pi/nono sandbox config with --no-sandbox) still takes precedence.
    # No --no-sandbox here: unsandboxed use keeps chromium's own sandbox intact.
    mkdir -p $out/share/playwright-cli
    cat > $out/share/playwright-cli/default-config.json <<'CONFEOF'
    {"browser":{"browserName":"chromium"}}
    CONFEOF
  '';

  meta = with lib; {
    description = "Browser automation CLI tool for coding agents (Claude Code, Copilot)";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "playwright-cli";
    platforms = platforms.linux ++ platforms.darwin;
  };
}


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
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "3a1bafc8b4e973c72d0364eb5b427d1ce0aa8317";
    hash = "sha256-hHK/GR5Drlt+e0L9kyNmn+ht1PCrVH6WrVbxGB1Wsxg=";
  };

  npmDepsHash = "sha256-Ulp6IttsZcOOA7LaYDpVKkBYbe2j4RFG8lJARWifOSk=";

  nativeBuildInputs = [ makeWrapper jq ];

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
      --set PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS "true"

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
  }
;
}
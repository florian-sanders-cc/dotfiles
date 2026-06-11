# Temporary local build until nixpkgs-unstable picks up 0.75.3
# Upstream: https://github.com/NixOS/nixpkgs/pull/520018
# Remove this file and the overlay override once nixos-unstable ships 0.75.3
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  ripgrep,
  makeBinaryWrapper,
  stdenvNoCC,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-coding-agent";
  version = "0.79.1";

  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MvH8e21GVfzRQ9vsxFNC1GHJfB9GZpqY1Z2t8GCUaiQ=";
  };

  npmDepsHash = "sha256-ZWdfDDs+Hv+GWTmsNmpWNlUDBOMALw7H4lwo7CJHVCM=";

  npmWorkspace = "packages/coding-agent";

  npmRebuildFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild

    npx tsgo -p packages/ai/tsconfig.build.json
    npx tsgo -p packages/tui/tsconfig.build.json
    npx tsgo -p packages/agent/tsconfig.build.json
    npm run build --workspace=packages/coding-agent

    runHook postBuild
  '';

  postInstall = ''
    local nm="$out/lib/node_modules/pi-monorepo/node_modules"

    for ws in @earendil-works/pi-ai:packages/ai \
              @earendil-works/pi-agent-core:packages/agent \
              @earendil-works/pi-tui:packages/tui; do
      IFS=: read -r pkg src <<< "$ws"
      rm "$nm/$pkg"
      cp -r "$src" "$nm/$pkg"
    done

    find "$nm" -type l -lname '*/packages/*' -delete
    find "$nm/.bin" -xtype l -delete
  ''
  + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    find "$nm/koffi/build/koffi" -mindepth 1 -maxdepth 1 -type d \
      ! -name 'darwin_*' -exec rm -r {} +
    rm -rf \
      "$nm/@anthropic-ai/sandbox-runtime/dist/vendor/seccomp" \
      "$nm/@anthropic-ai/sandbox-runtime/vendor/seccomp"
  '';

  postFixup = "wrapProgram $out/bin/pi --prefix PATH : ${lib.makeBinPath [ ripgrep ]}";

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgram = "${placeholder "out"}/bin/pi";
  versionCheckProgramArg = "--version";

  meta = {
    description = "Coding agent CLI with read, bash, edit, write tools and session management";
    homepage = "https://pi.dev/";
    downloadPage = "https://www.npmjs.com/package/@earendil-works/pi-coding-agent";
    changelog = "https://github.com/earendil-works/pi/blob/main/packages/coding-agent/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ munksgaard ];
    mainProgram = "pi";
  };
})

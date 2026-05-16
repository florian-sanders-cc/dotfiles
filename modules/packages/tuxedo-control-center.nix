{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeWrapper,
  python3,
  node-gyp,
  nodejs_24,
  electron_41,
  udev,
  gnugrep,
  gawk,
  xrandr,
  procps,
  which,
}:

buildNpmPackage rec {
  pname = "tuxedo-control-center";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "tuxedocomputers";
    repo = "tuxedo-control-center";
    rev = "v${version}";
    hash = "sha256-ucsgzuTHZ1SL23l84EEBnzjDnXJ5RFHj/Zx4rx1YbxA=";
  };

  nodejs = nodejs_24;

  npmDepsHash = "sha256-j8fBwDdo2zHTbIo28My4PZijgqgTcalNHHR9s1VuBqA=";

  # git+https:// deps in package.json (dbus-next, node-ble, usocket)
  forceGitDeps = true;
  # node-gyp writes into npm cache dir
  makeCacheWritable = true;

  # Skip postinstall: runs electron-builder install-app-deps + patch-package
  # which both require network access and are irrelevant for our build path.
  npmInstallFlags = [ "--ignore-scripts" ];

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  NG_CLI_ANALYTICS = "false";

  nativeBuildInputs = [
    makeWrapper
    python3
    node-gyp
  ];

  buildInputs = [
    # libudev for TuxedoIOAPI.node native addon
    udev
  ];

  postPatch = ''
    # --- TccPaths.ts: redirect hardcoded /opt/... and /etc/tcc paths ---
    # Use double-quoted replacements so $out expands to the real store path.
    substituteInPlace src/common/classes/TccPaths.ts \
      --replace-fail \
        "'/opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/service/tccd'" \
        "'$out/bin/tccd'" \
      --replace-fail \
        "'/opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/camera/cameractrls.py'" \
        "'$out/data/camera/cameractrls.py'" \
      --replace-fail \
        "'/opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/camera/v4l2_kernel_names.json'" \
        "'$out/data/camera/v4l2_kernel_names.json'" \
      --replace-fail \
        "'/etc/tcc/settings'" \
        "'/var/lib/tcc/settings'" \
      --replace-fail \
        "'/etc/tcc/profiles'" \
        "'/var/lib/tcc/profiles'" \
      --replace-fail \
        "'/etc/tcc/webcam'" \
        "'/var/lib/tcc/webcam'" \
      --replace-fail \
        "'/etc/tcc/fantables'" \
        "'/var/lib/tcc/fantables'"

    # --- Polkit policy: fix exec.path to point to the Nix store binary ---
    substituteInPlace src/dist-data/com.tuxedocomputers.tccd.policy \
      --replace-fail \
        '/opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/service/tccd' \
        "$out/bin/tccd"

    # --- systemd service file ---
    substituteInPlace src/dist-data/tccd.service \
      --replace-fail \
        '/opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/service/tccd' \
        "$out/bin/tccd"

    # --- Desktop entry: GUI ---
    substituteInPlace src/dist-data/tuxedo-control-center.desktop \
      --replace-fail \
        '"/opt/tuxedo-control-center/tuxedo-control-center"' \
        "$out/bin/tuxedo-control-center" \
      --replace-fail \
        '/opt/tuxedo-control-center/resources/dist/tuxedo-control-center/data/dist-data/tuxedo-control-center_256.svg' \
        "$out/share/icons/hicolor/scalable/apps/tuxedo-control-center.svg"

    # --- Desktop entry: tray ---
    substituteInPlace src/dist-data/tuxedo-control-center-tray.desktop \
      --replace-fail \
        '/opt/tuxedo-control-center/tuxedo-control-center' \
        "$out/bin/tuxedo-control-center"
  '';

  buildPhase = ''
    runHook preBuild

    export PATH="$PWD/node_modules/.bin:$PATH"
    export NO_UPDATE_NOTIFIER=true
    export npm_config_nodedir=${nodejs_24}

    # 1. Electron main process (tsc -p ./src/e-app)
    tsc -p ./src/e-app

    # 2. Service app TypeScript compile
    tsc -p ./src/service-app
    cp ./src/package.json ./dist/tuxedo-control-center/service-app/package.json

    # 3. Native addon (TuxedoIOAPI.node)
    node-gyp configure --release
    node-gyp rebuild --release

    # 4. Copy native lib, then bundle with esbuild (replaces pkg-build-service)
    cp ./build/Release/TuxedoIOAPI.node \
       ./dist/tuxedo-control-center/service-app/native-lib/
    mkdir -p ./dist/tuxedo-control-center/data/service
    esbuild ./dist/tuxedo-control-center/service-app/service-app/main.js \
      --tree-shaking=true --bundle --minify --drop:debugger \
      --define:DEBUG=false --platform=node \
      --loader:.node=copy --asset-names=[name] \
      --outfile=./dist/tuxedo-control-center/service-app/service-app/esbuild.js

    # 5. Angular frontend
    cp CHANGELOG.md ./src/ng-app/assets/
    ng build --configuration production --aot true --optimization true

    # 6. Copy dist-data, camera scripts
    cp -r ./src/dist-data ./dist/tuxedo-control-center/data
    mkdir -p ./dist/tuxedo-control-center/data/camera
    cp ./src/cameractrls/cameractrls.py \
       ./src/cameractrls/v4l2_kernel_names.json \
       ./dist/tuxedo-control-center/data/camera/

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./dist/tuxedo-control-center/. $out/

    # node_modules needed at runtime by the esbuild bundle and electron app
    cp -r ./node_modules $out/node_modules

    # systemd units
    install -Dm644 src/dist-data/tccd.service \
      $out/lib/systemd/system/tccd.service
    install -Dm644 src/dist-data/tccd-sleep.service \
      $out/lib/systemd/system/tccd-sleep.service

    # D-Bus policy
    install -Dm644 src/dist-data/com.tuxedocomputers.tccd.conf \
      $out/share/dbus-1/system.d/com.tuxedocomputers.tccd.conf

    # Polkit policy
    install -Dm644 src/dist-data/com.tuxedocomputers.tccd.policy \
      $out/share/polkit-1/actions/com.tuxedocomputers.tccd.policy

    # Desktop files
    install -Dm644 src/dist-data/tuxedo-control-center.desktop \
      $out/share/applications/tuxedo-control-center.desktop
    install -Dm644 src/dist-data/tuxedo-control-center-tray.desktop \
      $out/share/applications/tuxedo-control-center-tray.desktop

    # Icons
    install -Dm644 src/dist-data/tuxedo-control-center_256.svg \
      $out/share/icons/hicolor/scalable/apps/tuxedo-control-center.svg
    install -Dm644 src/dist-data/tuxedo-control-center_256.png \
      $out/share/icons/hicolor/256x256/apps/tuxedo-control-center.png

    # udev rule: generate with real $out path so udevadm verify passes.
    # $devnode and $env{...} are udev variables — escaped so they survive
    # into the installed rule as literals.
    install -Dm644 /dev/null $out/lib/udev/rules.d/99-webcam.rules
    cat > $out/lib/udev/rules.d/99-webcam.rules <<EOF
SUBSYSTEM=="video4linux", ACTION=="add", KERNEL=="video[0-9]*", RUN+="${python3}/bin/python3 $out/data/camera/cameractrls.py -s \$devnode,\$env{ID_VENDOR_ID},\$env{ID_MODEL_ID},/var/lib/tcc/webcam,$out/data/camera/v4l2_kernel_names.json"
EOF

    runHook postInstall
  '';

  postFixup = ''
    mkdir -p $out/bin

    # Patch environmentIsProduction to always be true.
    # Without an asar archive, app.isPackaged returns false and the save code
    # falls back to a non-existent cwd-relative tccd path instead of
    # TccPaths.TCCD_EXEC_FILE, causing profile saves to silently fail.
    substituteInPlace $out/e-app/e-app/backendAPIs/utilsAPI.js \
      --replace-fail \
        'exports.environmentIsProduction = electron_1.app.isPackaged;' \
        'exports.environmentIsProduction = true;'


    # tccd daemon: run the esbuild bundle with Node instead of pkg binary
    makeWrapper ${nodejs_24}/bin/node $out/bin/tccd \
      --add-flags "$out/service-app/service-app/esbuild.js" \
      --prefix PATH : "${lib.makeBinPath [ gnugrep gawk xrandr procps which ]}" \
      --prefix NODE_PATH : "$out/node_modules"

    # GUI wrapper: written as a shell script rather than via makeWrapper so
    # that $HOME expands at runtime. makeWrapper --add-flags bakes $HOME at
    # build time (Nix sandbox sets HOME=/build).
    {
      printf '#!/bin/sh\n'
      printf 'export PATH="%s''${PATH:+:$PATH}"\n' "${lib.makeBinPath [ python3 ]}"
      printf 'export NODE_PATH="%s''${NODE_PATH:+:$NODE_PATH}"\n' "$out/node_modules"
      printf 'exec "%s" \\\n' "${electron_41}/bin/electron"
      printf '  "%s" \\\n' "$out/e-app/e-app/main.js"
      printf '  --no-tccd-version-check \\\n'
      printf '  --user-data-dir="$HOME/.config/tuxedo-control-center" \\\n'
      printf '  "$@"\n'
    } > $out/bin/tuxedo-control-center
    chmod +x $out/bin/tuxedo-control-center
  '';
}

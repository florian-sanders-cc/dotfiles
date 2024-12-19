{
  pkgs ? import <nixpkgs> { },
}:

let
  fhsEnv = pkgs.buildFHSEnv {
    name = "nodejs-project-env";
    targetPkgs =
      pkgs: with pkgs; [
        nodeBinary
        glib
        nss
        nspr
        at-spi2-core # libatspi.so.0
        at-spi2-atk # libatk-bridge-2.0.so.0
        atk # libatk-1.0.so.0
        cups # libcups.so.2
        libdrm # libdrm.so.2
        dbus # libdbus-1.so.3
        xorg.libX11 # libX11.so.6
        xorg.libXcomposite # libXcomposite.so.1
        xorg.libXdamage # libXdamage.so.1
        xorg.libXext # libXext.so.6
        xorg.libXfixes # libXfixes.so.3
        xorg.libXrandr # libXrandr.so.2
        mesa # libgbm.so.1
        expat # libexpat.so.1
        xorg.libxcb # libxcb.so.1
        libxkbcommon # libxkbcommon.so.0
        pango # libpango-1.0.so.0
        cairo # libcairo.so.2
        alsa-lib # libasound.so.2
        wayland # libwayland-client.so.0
        systemd
      ];
    runScript = "bash";
  };

in
pkgs.mkShell {
  name = "nodejs-project";

  buildInputs = [
    nodeBinary
    startFhs # Include the wrapper script
  ];

  shellHook =
    if npmVersion != "null" then
      ''
        # Create npm prefix directory if it doesn't exist
        mkdir -p $NPM_PREFIX/npm-$PACKAGE_NPM_VERSION
        npm set prefix $NPM_PREFIX/npm-$PACKAGE_NPM_VERSION
        PATH="$NPM_PREFIX/npm-$PACKAGE_NPM_VERSION/bin:$PATH"
        if [ "$(npm -v)" != ${npmVersion} ]; then
          npm i -g npm@$PACKAGE_NPM_VERSION
        fi
        echo "Type 'start-fhs' to enter the FHS environment"
      ''
    else
      ''
        echo "Type 'start-fhs' to enter the FHS environment"
      '';
}

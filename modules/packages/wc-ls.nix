{
  stdenv,
  fetchurl,
  lib,
  nodejs,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "wc-language-server";
  version = "0.0.20";

  src = fetchurl {
    url = "https://open-vsx.org/api/wc-toolkit/web-components-language-server/${version}/file/wc-toolkit.web-components-language-server-${version}.vsix";
    hash = "sha256-RGpTtxJze9IdU9s4I5kbd7J2yIMWm41C5+PtkHcgvkU=";
  };

  nativeBuildInputs = [
    nodejs
    unzip
  ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  installPhase = ''
        runHook preInstall

        mkdir -p $out/bin
        mkdir -p $out/lib/wc-language-server

        # Extract and copy the extension contents
        cp -r extension/. $out/lib/wc-language-server/

        # Create wrapper script that runs server.js from dist directory
        cat > $out/bin/wc-language-server << EOF
    #!/bin/sh
    exec ${nodejs}/bin/node $out/lib/wc-language-server/dist/server.js "\$@"
    EOF

        chmod +x $out/bin/wc-language-server

        runHook postInstall
  '';

  meta = with lib; {
    description = "Language server for Web Components";
    homepage = "https://github.com/wc-toolkit/wc-language-server";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
})

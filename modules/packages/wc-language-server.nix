{
  stdenv,
  fetchurl,
  lib,
  nodejs,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wc-language-server";
  version = "0.0.6";

  src = fetchurl {
    url = "https://wc-toolkit.gallerycdn.vsassets.io/extensions/wc-toolkit/web-components-language-server/0.0.6/1755092259305/Microsoft.VisualStudio.Services.VSIXPackage";
    hash = "sha256-tuIY2+6jJEOH2tpAbatu09zY33mmtzY8lnRWy+/B/E0=";
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
cd $out/lib/wc-language-server
exec ${nodejs}/bin/node dist/server.js "\$@"
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
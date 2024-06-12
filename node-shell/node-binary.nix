{ nodeVersion
, autoPatchelfHook
, stdenv
,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nodejs-binary";
  version = "${nodeVersion}";

  src = builtins.fetchurl "https://nodejs.org/dist/v${nodeVersion}/node-v${nodeVersion}-linux-x64.tar.xz";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    mkdir -p $out
    cd $out
    tar -xvf $src --strip-components 1
  '';
})


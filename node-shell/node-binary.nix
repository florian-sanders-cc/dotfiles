{
  nodeVersion,
  fetchurl,
  autoPatchelfHook,
  stdenv,
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

# stdenv.mkDerivation rec {
#   name = "node-binary";
#
#   src = builtins.fetchurl "https://nodejs.org/dist/v${nodeVersion}/node-v${nodeVersion}-linux-x64.tar.xz";
#   sourceRoot = ".";
#
#   nativeBuildInputs = [
#     autoPatchelfHook 
#   ];
#
#   buildInputs = [ stdenv.cc.cc.lib ];
#
#   installPhase = ''
#     mkdir -p $out
#     cd $out
#     tar -xvf $src --strip-components 1
#   '';
# }

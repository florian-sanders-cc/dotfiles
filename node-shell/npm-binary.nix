{
  npmVersion,
  npmPackageHash,
  npmDepsHash,
  fetchurl,
  fetchFromGitHub,
  buildNpmPackage,
  stdenv,
  pkgs,
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "npm-test";
  version = "${npmVersion}";

  src = fetchFromGitHub {
    owner = "npm";
    repo = "cli";
    rev = "v${npmVersion}";
    hash = "${npmPackageHash}";
  };

  nativeBuildInputs = [ pkgs.nodejs ];

  buildInputs = [
     pkgs.nodejs_18
  ];

  npmBuilt = buildNpmPackage {
    pname = "npm";
    inherit version src npmDepsHash;
    dontNpmBuild = true;
  };

  installPhase = ''
    cp -r ${npmBuilt} $out
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

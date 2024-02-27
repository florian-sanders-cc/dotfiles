{
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "random-labels";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "random-labels";
    rev = "v${version}";
    hash = "sha256-7MxZ2Ez7nixCG5XHwIpeKSSGEGweyLVnqefvf7SUV+g=";
  };

  nativeBuildInputs = [ nodejs ];

  buildInputs = [
     nodejs
  ];

  randomLabelsBuilt = buildNpmPackage {
    pname = "random-labels";
    inherit version src;
    npmDepsHash = "sha256-rtWBV1ziMuiNAyi3K/Ay5srxmjRmN2FlZ6e0uI2ZZzc=";
    dontNpmBuild = true;
  };

  installPhase = ''
    cp -r ${randomLabelsBuilt} $out
  '';
})

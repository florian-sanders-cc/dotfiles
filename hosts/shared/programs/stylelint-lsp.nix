{ stdenv
, fetchFromGitHub
, buildNpmPackage
, nodejs
, nodePackages
, makeWrapper
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "stylelint-lsp";
  version = "e54cdeabc7f2c19d47323b54c188037489792f78";

  src = fetchFromGitHub {
    owner = "florian-sanders-cc";
    repo = "stylelint-lsp";
    rev = "${version}";
    hash = "sha256-Y5t1rpxU5ZMj65xAxQwE7zRDl50rv00aLUTXldekeEs=";
  };

  nativeBuildInputs = [
    nodejs
    nodePackages.pnpm
  ];

  buildInputs = [
    nodejs
    makeWrapper
  ];

  stylelintLspBuilt = buildNpmPackage {
    pname = "stylelint-lsp";
    npmDepsHash = "sha256-CUW4DZ5oDUXgqWu5najC3Mgstl7OfELMBWECtCyuAgg=";
    inherit version src;
  };

  installPhase = ''
    cp -r ${stylelintLspBuilt} $out
  '';

})

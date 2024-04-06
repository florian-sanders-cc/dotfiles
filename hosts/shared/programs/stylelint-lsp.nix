{ stdenv
, fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "stylelint-lsp";
  version = "e54cdeabc7f2c19d47323b54c188037489792f78";

  src = fetchFromGitHub {
    owner = "florian-sanders-cc";
    repo = "stylelint-lsp";
    rev = "${version}";
    hash = "sha256-Y5t1rpxU5ZMj65xAxQwE7zRDl50rv00aLUTXldekeEs=";
  };

  npmDepsHash = "sha256-CUW4DZ5oDUXgqWu5najC3Mgstl7OfELMBWECtCyuAgg=";
}

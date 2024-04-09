{ fetchFromGitHub
, buildNpmPackage
, stdenv
}:

buildNpmPackage rec {
  pname = "clever-tools";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "clever-tools";
    rev = "${version}";
    hash = "sha256-v60evwLnMxU5EGILAvCTtMsO0fWpjfc0TA7upHcrq9U=";
  };

  npmDepsHash = "sha256-AK1CNtFTM3wgel5L2ekmXWHZhIerqKPd5i7X/kJm7No=";
  dontNpmBuild = true;
}

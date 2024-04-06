{ fetchFromGitHub
, buildNpmPackage
, stdenv
}:

buildNpmPackage rec {
  pname = "clever-tools";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "clever-tools";
    rev = "${version}";
    hash = "sha256-3su+QU7TsgOghV35pqgLqzGlJNbSQ54IC2XxRh8RGkc=";
  };

  npmDepsHash = "sha256-QZ1t0tA15ztQWnaYiajt4JdzzvqNxn1IjaVP/D9WyQk=";
  dontNpmBuild = true;
}

{
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "random-labels";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "random-labels";
    rev = "v${version}";
    hash = "sha256-SMxyo8cuJeTqXvHkxdNuU9643RB1pyalZb9vA9l+Ohk=";
  };

  npmDepsHash = "sha256-i8AbJmpWAH3775WPRv+jCii89KJ1R5fA/CKaeevyuMw=";
  dontNpmBuild = true;
}

{
    lib,
    fetchFromGitHub,
    stdenv,
    nodejs,
    buildNpmPackage,
}: 

stdenv.mkDerivation (finalAttrs: rec {
  pname = "tree-sitter-javascript";
  version = "v0.20.3";

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-javascript";
    rev = "${version}";
    hash = "sha256-LyhWCoUZ0tvdIXiW7jTpbYcdR98IFrYlBPiYRK+xw8c=";
  };

  nativeBuildInputs = [
    nodejs
  ];
  buildInputs = [
    nodejs
  ];


  installPhase = ''
    ls
    cp -r . $out
  '';
})

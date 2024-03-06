{ stdenv
, fetchFromGitHub
, buildNpmPackage
, nodejs
,
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "random-labels";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "random-labels";
    rev = "v${version}";
    hash = "sha256-CBB2ZS/CvCHjKgnMd+LvJ/GPcWVq3T1iRd3iLZ/G7wM=";
  };

  nativeBuildInputs = [ nodejs ];

  buildInputs = [
    nodejs
  ];

  randomLabelsBuilt = buildNpmPackage {
    pname = "random-labels";
    inherit version src;
    npmDepsHash = "sha256-WrtYlsf7YtbQfKYFeuR3D3C6KcS6UktbbEOIJ7gIaVQ=";
    dontNpmBuild = true;
  };

  installPhase = ''
    cp -r ${randomLabelsBuilt} $out
  '';
})

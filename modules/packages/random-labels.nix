{
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "random-labels";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "random-labels";
    rev = "v${version}";
    hash = "sha256-CBB2ZS/CvCHjKgnMd+LvJ/GPcWVq3T1iRd3iLZ/G7wM=";
  };

  npmDepsHash = "sha256-WrtYlsf7YtbQfKYFeuR3D3C6KcS6UktbbEOIJ7gIaVQ=";
  dontNpmBuild = true;
}

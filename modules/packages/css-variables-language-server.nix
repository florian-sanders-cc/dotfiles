{ fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "css-variables-language-server";
  version = "b50a29c1d6c90501de4830eda3fc49a5a7c91a2f";

  src = fetchFromGitHub {
    owner = "vunguyentuan";
    repo = "vscode-css-variables";
    rev = "${version}";
    hash = "sha256-U2/xEggcm/HDC7rCOPuXByOEYKpCygD1cRm1ACK5g0g=";
  };

  npmDepsHash = "sha256-wLgngAfhOZ45ox+bCco/K5nd+8ca6t8E3ocBD30zZHs=";
}

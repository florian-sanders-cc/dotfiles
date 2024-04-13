{ stdenv
, fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "postcss-lit";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "43081j";
    repo = "postcss-lit";
    rev = "v${version}";
    hash = "sha256-4QZlUrxDBshoQDAVKrUITSCcX5Wk/pd+M0m3DnULRYQ=";
  };

  npmDepsHash = "sha256-EoS0n16aoAW000hiDIxYZ2sPfdN+zIuwPdrEMBy2HcM=";
  dontNpmBuild = true;
}

{
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "random-labels";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "random-labels";
    rev = "v${version}";
    hash = "sha256-mB2sUIOpzC0fevqCDOL5eWO5vVm9jpI4vKEDy8UCt1Q=";
  };

  npmDepsHash = "sha256-j+5d/5prtZeyl5D5WMhT/Y/txAs1y6jnTqvWChOqSj0=";
  dontNpmBuild = true;
}

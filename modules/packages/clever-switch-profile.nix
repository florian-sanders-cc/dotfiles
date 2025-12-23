{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  ...
}:

buildNpmPackage rec {
  pname = "clever-switch-profile";
  version = "4.4.1";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "clever-tools";
    rev = version;
    hash = "sha256-ssbm2XevvB1zzVVeOUTxUUKcD8smlsOjy9efnFLw03M=";
  };

  installPhase = ''
    cp -r . $out
    makeWrapper ${nodejs_22}/bin/node $out/bin/clever-switch-profile \
      --add-flags "$out/scripts/switch-profile.js"
  '';

  npmDepsHash = "sha256-VxFxMvbkEnjooSq1Ats4tC8Dcqr3EVffccxOXNha4MY=";
  dontNpmBuild = true;
}

{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  ...
}:

buildNpmPackage rec {
  pname = "clever-switch-profile";
  version = "bf6a2c2fd4167a53a60446b5353e9e75c696436a";

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "clever-tools";
    rev = version;
    hash = "sha256-SEX4mTdvY5NL2/FUdYKJob0B+XvmXWaxM0uHR8cgFak=";
  };

  installPhase = ''
    cp -r . $out
    makeWrapper ${nodejs_24}/bin/node $out/bin/clever-switch-profile \
      --add-flags "$out/scripts/switch-profile.js"
  '';

  npmDepsHash = "sha256-4vW6FfYgaYuqLs34HoOhhBkyV2bWUlAxez+3WtDD03g=";
  dontNpmBuild = true;
}

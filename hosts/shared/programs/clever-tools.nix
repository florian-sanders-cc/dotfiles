{ fetchFromGitHub
, buildNpmPackage
, stdenv
, pkgs
}:

buildNpmPackage rec {
  pname = "clever-tools";
  version = "3.6.0";

  nodejs = pkgs.nodejs-18_x;

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "clever-tools";
    rev = "${version}";
    hash = "sha256-3LZ04YeVrKXa9rk3Wh4yS4zk4cUyT0fw7VnsaPXdKgs=";
  };

  npmDepsHash = "sha256-dJpe+YgklzuwBF1FnTQxBCiIBF2gaG9MIp0cfRl+YfQ=";
  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/share/{bash-completion/completions,zsh/site-functions}
    $out/bin/clever --bash-autocomplete-script $out/bin/clever > $out/share/bash-completion/completions/clever
    $out/bin/clever --zsh-autocomplete-script $out/bin/clever > $out/share/zsh/site-functions/_clever
  '';
}

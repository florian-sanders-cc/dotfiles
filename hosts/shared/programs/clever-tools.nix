{ fetchFromGitHub
, buildNpmPackage
, stdenv
, pkgs
}:

buildNpmPackage rec {
  pname = "clever-tools";
  version = "3.6.1";

  nodejs = pkgs.nodejs-18_x;

  src = fetchFromGitHub {
    owner = "CleverCloud";
    repo = "clever-tools";
    rev = "${version}";
    hash = "sha256-qNmBjjYuXGzCaBuBdqICCkmSYqdIH1KUfuDHRG+cKuM=";
  };

  npmDepsHash = "sha256-2hn3HXMJm+jw0qTXXTpzLKMlKtfzToAekStWbzqjoAw=";
  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/share/{bash-completion/completions,zsh/site-functions}
    $out/bin/clever --bash-autocomplete-script $out/bin/clever > $out/share/bash-completion/completions/clever
    $out/bin/clever --zsh-autocomplete-script $out/bin/clever > $out/share/zsh/site-functions/_clever
  '';
}

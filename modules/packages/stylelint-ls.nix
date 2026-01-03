{
  lib,
  stdenv,
  fetchurl,
  unzip,
  makeWrapper,
  nodejs,
}:

stdenv.mkDerivation rec {
  pname = "stylelint-ls";
  version = "1.6.0";

  src = fetchurl {
    url = "https://open-vsx.org/api/stylelint/vscode-stylelint/${version}/file/stylelint.vscode-stylelint-${version}.vsix";
    sha256 = "sha256-q66+xEzrU58+THQcwJ542Vd2V//kN8NrFQX2ml4V/38=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
    nodejs
  ];

  unpackPhase = ''
    unzip -q $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/stylelint-ls

    cp -r extension/* $out/lib/stylelint-ls/

    makeWrapper ${nodejs}/bin/node $out/bin/stylelint-ls --add-flags $out/lib/stylelint-ls/dist/start-server.js
  '';

  meta = with lib; {
    description = "Stylelint language server extracted from VSCode extension";
    homepage = "https://github.com/stylelint/vscode-stylelint";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}

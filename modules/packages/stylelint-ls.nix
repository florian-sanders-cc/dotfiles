{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  makeWrapper,
  lib,
  libsecret,
  pkg-config,
}:

buildNpmPackage rec {
  pname = "stylelint-ls";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "stylelint";
    repo = "vscode-stylelint";
    rev = "@stylelint/language-server@${version}";
    hash = "sha256-QRFc//mG7e0G7A7ZmwQzakU7RvegTPaJ6pGzvan2mwQ=";
  };

  npmDepsHash = "sha256-LDegvLvKbw9c+iOmfx0q0Himf46MDh2TmraNqhFPE/Q=";

  nativeBuildInputs = [
    nodejs_22
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libsecret
  ];

  buildPhase = ''
    npm run build-bundle
  '';

  installPhase = ''
    mkdir -p $out/bin && cp -r dist/. $out/bin
    makeWrapper ${nodejs_22}/bin/node $out/bin/stylelint-ls \
      --add-flags "$out/bin/start-server.js"
  '';

  meta = with lib; {
    description = "Stylelint language server extracted from VSCode extension";
    homepage = "https://github.com/stylelint/vscode-stylelint";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}

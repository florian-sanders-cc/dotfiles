{
  stdenv,
  fetchFromGitHub,
  lib,
  nodejs,
  unzip,
  pnpm,
  pnpmConfigHook,
  makeWrapper,
  fetchPnpmDeps,
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "wc-language-server";
  version = "@wc-toolkit/language-server@0.0.6";

  src = fetchFromGitHub {
    owner = "wc-toolkit";
    repo = "wc-language-server";
    rev = "${version}";
    sha256 = "sha256-9HjEUokJB5Z/hg0HR/azIIM5Dfxa27jyN0vO7POYbNg=";
  };

  nativeBuildInputs = [
    nodejs
    unzip
    pnpm
    pnpmConfigHook
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    fetcherVersion = 3;
    hash = "sha256-19UfrA1lTQ3dwG50eHlcTORAplha/0rt+RwT3fPv9XE=";
  };

  pnpmWorkspaces = [ "@wc-toolkit/language-server" ];

  buildPhase = ''
    runHook preBuild

    pnpm --filter=@wc-toolkit/language-server run bundle:single

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp packages/language-server/dist/wc-language-server.bundle.cjs $out/wc-language-server.cjs
    makeWrapper ${nodejs}/bin/node $out/bin/wc-language-server --add-flags $out/wc-language-server.cjs
  '';

  meta = with lib; {
    description = "Language server for Web Components";
    homepage = "https://github.com/wc-toolkit/wc-language-server";
    license = licenses.mit;
    platforms = platforms.all;
  };
})

{
  stdenv,
  fetchurl,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "pi-rtk-bash";
  version = "0.1.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-PAJxVQ67TKFLr20NRVe4EA3deHZsNKCeNSN0r0S1g8o=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/node_modules
    cp -r . $out/lib/node_modules/${pname}
    runHook postInstall
  '';

  meta = with lib; {
    description = "RTK-backed rtk_bash tool for Pi one-shot shell commands";
    homepage = "https://github.com/alexykn/pi-rtk-bash";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}

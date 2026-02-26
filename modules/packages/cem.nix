{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
}:

let
  version = "0.9.9";
  platform =
    {
      x86_64-linux = "x64";
      aarch64-linux = "arm64";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported platform");
in
stdenv.mkDerivation {
  pname = "cem";
  inherit version;

  src = fetchurl {
    url = "https://github.com/bennypowers/cem/releases/download/v${version}/cem-linux-${platform}";
    sha256 = "sha256-5Q/8Uf/xmI6iJImkwTbRUfYcy0wMDI6iUA0HdTlcdkk=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/cem
    chmod +x $out/cem

    makeWrapper $out/cem $out/bin/cem
  '';

  meta = with lib; {
    description = "The standards-based toolkit for Web Components - CLI, LSP, and MCP";
    homepage = "https://github.com/bennypowers/cem";
    license = licenses.gpl3;
    maintainers = [ ];
    mainProgram = "cem";
    platforms = platforms.all;
  };
}

{ stdenv, ... }:

stdenv.mkDerivation {
  name = "icons";
  version = "0.1.0";
  src = ../../dotfiles/icons;
  installPhase = ''
    cp -r . $out
  '';
}

{ stdenv, ... }:

stdenv.mkDerivation {
    name = "wallpapers";
    version = "0.1.0";
    src = ../../dotfiles/wallpapers;
    installPhase = ''
        cp -r . $out
    '';
}

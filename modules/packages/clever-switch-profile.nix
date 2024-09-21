{
  stdenv,
  pkgs,
  lib,
  ...
}:

stdenv.mkDerivation {
  name = "clever-switch-profile";
  version = "0.1.0";
  src = ../../dotfiles/clever-tools;
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ pkgs.nodejs-18_x ];
  installPhase = ''
    mkdir -p $out/bin
    cp clever-switch-profile.js $out/bin/clever-switch-profile
    wrapProgram $out/bin/clever-switch-profile \
      --prefix PATH : ${lib.makeBinPath [ pkgs.nodejs-18_x ]}
  '';
}

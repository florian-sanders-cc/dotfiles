{
  stdenv,
  pkgs,
  ...
}:

stdenv.mkDerivation {
  name = "clever-switch-profile";
  version = "0.1.0";
  src = ../../dotfiles/clever-tools;
  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/src
    cp clever-switch-profile.js $out/src
    makeWrapper ${pkgs.nodejs-18_x}/bin/node $out/bin/clever-switch-profile \
      --add-flags "$out/src/clever-switch-profile.js"
  '';
}

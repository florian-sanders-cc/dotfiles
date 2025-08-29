{ lib
, stdenv
, makeWrapper
, jq
, bash
,
}:

stdenv.mkDerivation rec {
  pname = "niri-smart-focus";
  version = "1.0.0";

  src = ./niri/scripts;

  nativeBuildInputs = [
    makeWrapper
  ];

  runtimeDeps = [
    jq
    bash
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Install smart-focus-ghostty
    install -Dm755 $src/smart-focus-ghostty $out/bin/smart-focus-ghostty

    # Install smart-focus-firefox  
    install -Dm755 $src/smart-focus-firefox $out/bin/smart-focus-firefox

    # Install smart-focus-chromium  
    install -Dm755 $src/smart-focus-chromium $out/bin/smart-focus-chromium

    runHook postInstall
  '';

  postFixup = ''
    # Wrap scripts to ensure runtime dependencies are available
    for script in $out/bin/*; do
      wrapProgram "$script" \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}
    done
  '';

  meta = with lib; {
    description = "Smart focus scripts for niri window manager";
    longDescription = ''
      Collection of smart focus scripts for the niri window manager.
      Provides intelligent window cycling and spawning for Ghostty terminal
      and Firefox browser applications.
      
      These scripts integrate with the niri compositor to provide smart
      window management - they will cycle through existing windows of the
      target application or spawn a new instance if none exist.
    '';
    homepage = "https://github.com/YaLTeR/niri";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}


{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  vulkan-loader,
  webkitgtk_4_1,
  gtk3,
  libsoup_3,
  alsa-lib,
  openssl,
  glib,
  cairo,
  gdk-pixbuf,
  xorg,
  libayatana-appindicator,
}:

stdenv.mkDerivation rec {
  pname = "handy";
  version = "0.7.0";

  src = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_${version}_amd64.deb";
    hash = "sha256-vjLFAq+BTZ/Dr9WJe0Dxu9Y+5jSITiASvRnwhJSahWk=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    vulkan-loader
    webkitgtk_4_1
    gtk3
    libsoup_3
    alsa-lib
    openssl
    glib
    cairo
    gdk-pixbuf
    xorg.libX11
    libayatana-appindicator
    stdenv.cc.cc.lib # libstdc++
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share

    cp -r usr/lib/Handy $out/lib/
    cp -r usr/share/* $out/share/

    install -Dm755 usr/bin/handy $out/bin/.handy-unwrapped

    # TODO: VK_ICD_FILENAMES is Intel-specific. Update for NVIDIA/AMD if needed.
    makeWrapper $out/bin/.handy-unwrapped $out/bin/handy \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
      --set GDK_BACKEND wayland \
      --set VK_ICD_FILENAMES /run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json

    runHook postInstall
  '';

  meta = with lib; {
    description = "Speech-to-text transcription app";
    homepage = "https://github.com/cjpais/Handy";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "handy";
  };
}

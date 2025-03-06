{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  libGL,
  libxkbcommon,
  xorg,
  openssl,
  alsa-lib,
  vulkan-loader,
  wayland,
}:

let
  version = "0.177.3-pre";
in
stdenv.mkDerivation rec {
  pname = "zed-preview";
  inherit version;

  # Fetch the Linux binary tarball
  src = fetchurl {
    url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-x86_64.tar.gz";
    sha256 = "sha256-kbDgamjPKUAxNg1pNUOg7e4pkiX74wdGJfL1mB5JJbs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # Libraries needed for Zed to run
  buildInputs = [
    stdenv.cc.cc.lib
    libGL
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    openssl
    alsa-lib
    vulkan-loader
    wayland
  ];

  installPhase = ''
    # Create the destination directory
    mkdir -p $out

    # Copy all directories from the app structure
    cp -r bin $out/
    cp -r lib $out/
    cp -r libexec $out/
    cp -r share $out/

    # Copy the licenses
    cp licenses.md $out/ || true

    # Check if zed exists and create wrapper
    if [ -f "$out/bin/zed" ]; then
      # Rename the original binary to avoid conflicts
      mv $out/bin/zed $out/bin/zed-original

      # Create a wrapper script that sets up the correct environment
      makeWrapper $out/bin/zed-original $out/bin/zed \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}

      # Create zed-preview as an additional alias
      ln -s $out/bin/zed $out/bin/zed-preview
    else
      echo "Could not find zed executable in bin directory"
      ls -la $out/bin
      exit 1
    fi
  '';

  meta = with lib; {
    description = "Zed editor preview release (v${version})";
    homepage = "https://zed.dev/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "zed";
  };
}

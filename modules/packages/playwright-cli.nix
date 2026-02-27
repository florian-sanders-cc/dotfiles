{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  stdenv,
  glib,
  nss,
  nspr,
  at-spi2-core,
  at-spi2-atk,
  atk,
  cups,
  libdrm,
  dbus,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcursor,
  libxi,
  libxrender,
  mesa,
  libgbm,
  expat,
  libxcb,
  libxkbcommon,
  pango,
  cairo,
  alsa-lib,
  wayland,
  systemd,
  gtk3,
  gdk-pixbuf,
  freetype,
  fontconfig,
  gnutls,
}:

let
  browserLibs = lib.makeLibraryPath [
    stdenv.cc.cc.lib # libstdc++
    glib
    nss
    nspr
    at-spi2-core
    at-spi2-atk
    atk
    cups
    libdrm
    dbus
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcursor
    libxi
    libxrender
    mesa
    libgbm
    expat
    libxcb
    libxkbcommon
    pango
    cairo
    alsa-lib
    wayland
    systemd
    gtk3
    gdk-pixbuf
    freetype
    fontconfig
    gnutls
  ];
in
buildNpmPackage rec {
  pname = "playwright-cli";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "fa6f6bcca9c3eeb4ac71051f83ebd623ac51d765";
    hash = "sha256-XjYib26oVoTEmjD5wHMlauEdtXkaC60OBitb1mj/Xnk=";
  };

  npmDepsHash = "sha256-4x3ozVrST6LtLoHl9KtmaOKrkYwCK84fwEREaoNaESc=";

  nativeBuildInputs = [ makeWrapper ];

  dontNpmBuild = true;

  postInstall = ''
    wrapProgram $out/bin/playwright-cli \
      --set NIX_LD_LIBRARY_PATH "${browserLibs}" \
      --set PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS true
  '';

  meta = with lib; {
    description = "Browser automation CLI tool for coding agents (Claude Code, Copilot)";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "playwright-cli";
    platforms = platforms.linux ++ platforms.darwin;
  };
}

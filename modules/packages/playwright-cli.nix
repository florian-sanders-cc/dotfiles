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
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "playwright-cli";
    rev = "0406adaed4c6ba95bbfa6952229e76188bc59993";
    hash = "sha256-8f/wFO4hSytpy3kEPyScoMWXWyeTl/SKoc3vD7xYaKo=";
  };

  npmDepsHash = "sha256-DK+nTRdVKznerAMK7McCCgr2OK4GXymbmgyR9qU/aH4=";

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

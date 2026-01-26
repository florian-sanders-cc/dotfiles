{
  lib,
  warp-terminal,
  makeWrapper,
  wayland,
  symlinkJoin,
}:

symlinkJoin {
  name = "warp-terminal-wayland";
  paths = [ warp-terminal ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/warp-terminal \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ wayland ]}
  '';

  meta = warp-terminal.meta // {
    description = "Warp terminal wrapped for Wayland support";
  };
}

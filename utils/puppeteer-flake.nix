{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      fhsEnv = pkgs.buildFHSEnv {
        name = "nodejs-project-env";
        targetPkgs =
          pkgs: with pkgs; [
            glib
            nss
            nspr
            at-spi2-core # libatspi.so.0
            at-spi2-atk # libatk-bridge-2.0.so.0
            atk # libatk-1.0.so.0
            cups # libcups.so.2
            libdrm # libdrm.so.2
            dbus # libdbus-1.so.3
            libX11 # libX11.so.6
            xorg.libXcomposite # libXcomposite.so.1
            xorg.libXdamage # libXdamage.so.1
            xorg.libXext # libXext.so.6
            xorg.libXfixes # libXfixes.so.3
            xorg.libXrandr # libXrandr.so.2
            mesa # libgbm.so.1
            expat # libexpat.so.1
            xorg.libxcb # libxcb.so.1
            libxkbcommon # libxkbcommon.so.0
            pango # libpango-1.0.so.0
            cairo # libcairo.so.2
            alsa-lib # libasound.so.2
            wayland # libwayland-client.so.0
            systemd
          ];
        runScript = "bash";
      };
    in
    {
      devShells.${system}.default = fhsEnv.env;
    };
}

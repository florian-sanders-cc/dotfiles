{
  description = "Node.js + Playwright dev environment via nix-ld";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        MISE_NODE_COMPILE = "0";

        NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
          with pkgs;
          [
            stdenv.cc.cc.lib # libstdc++

            # Playwright browser dependencies
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
          ]
        );

        packages = [
          pkgs.mise
        ];

        shellHook = ''
          echo "🔧 nix-ld environment active — Node.js and Playwright libraries available"
        '';
      };
    };
}

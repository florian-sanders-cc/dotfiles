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

            # Chromium / Firefox
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

            # WebKit extras
            icu
            libepoxy
            libevent
            gst_all_1.gstreamer
            libjpeg
            opus
            libpng
            libsoup_3
            libwebp
            harfbuzz
            zlib
            libwpe
            libglvnd
            bzip2
            brotli
            libxml2
            libxslt
            libavif
            lcms2
            enchant
            libsecret
            libmanette
            libevdev
            libgcrypt
            hyphen
            woff2
            sqlite
          ]
        );

        PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
        PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";

        packages = [
          pkgs.mise
          pkgs.jq
        ];

        shellHook = ''
          export PLAYWRIGHT_BROWSERS_PATH="$HOME/.cache/playwright-browsers"

          link-playwright-browsers() {
            local nix_browsers="${pkgs.playwright-driver.browsers}"
            local nix_json="${pkgs.playwright-driver}/browsers.json"

            # Find project's playwright-core browsers.json
            local pkg_dir=""
            local lookdir="$PWD"
            while [ "$lookdir" != "/" ]; do
              pkg_dir=$(find "$lookdir" -maxdepth 6 -path '*/node_modules/.pnpm/playwright-core@*/node_modules/playwright-core/package.json' -print -quit 2>/dev/null)
              [ -n "$pkg_dir" ] && break
              pkg_dir=$(find "$lookdir" -maxdepth 6 -path '*/node_modules/.pnpm/playwright@*/node_modules/playwright/package.json' -print -quit 2>/dev/null)
              [ -n "$pkg_dir" ] && break
              lookdir=$(dirname "$lookdir")
            done
            if [ -z "$pkg_dir" ]; then
              echo "No playwright package found in node_modules."
              return 1
            fi

            local bundled_json="$(dirname "$pkg_dir")/browsers.json"
            if [ ! -f "$bundled_json" ]; then
              echo "browsers.json not found at $bundled_json"
              return 1
            fi

            mkdir -p "$PLAYWRIGHT_BROWSERS_PATH"

            # Link all nixpkgs browsers
            ln -sfn "$nix_browsers"/* "$PLAYWRIGHT_BROWSERS_PATH/"

            # Create compat symlinks for mismatched revisions
            for name in chromium chromium-headless-shell firefox webkit ffmpeg; do
              local bundled_rev=$(jq -r --arg n "$name" '.browsers[] | select(.name==$n).revision' "$bundled_json" 2>/dev/null)
              local nix_rev=$(jq -r --arg n "$name" '.browsers[] | select(.name==$n).revision' "$nix_json")

              if [ -n "$bundled_rev" ] && [ -n "$nix_rev" ] && [ "$bundled_rev" != "$nix_rev" ]; then
                local dir_name=$(echo "$name" | tr '-' '_')
                if [ -e "$PLAYWRIGHT_BROWSERS_PATH/$dir_name-$nix_rev" ]; then
                  ln -sfn "$dir_name-$nix_rev" "$PLAYWRIGHT_BROWSERS_PATH/$dir_name-$bundled_rev"
                fi
              fi
            done

            echo "Playwright browsers linked from nixpkgs."
          }

          echo "Node.js dev environment active (nix-ld)."
          if [ -d "$PLAYWRIGHT_BROWSERS_PATH" ] && [ -n "$(ls -A "$PLAYWRIGHT_BROWSERS_PATH" 2>/dev/null)" ]; then
            echo "Playwright browsers: linked at $PLAYWRIGHT_BROWSERS_PATH"
          else
            echo "Playwright browsers: not linked — run: link-playwright-browsers"
          fi
          echo ""
        '';
      };
    };
}

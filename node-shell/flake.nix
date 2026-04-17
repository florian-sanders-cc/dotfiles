{
  description = "Node.js + Playwright dev environment using nixpkgs-patched browsers";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      playwrightVersion = pkgs.playwright-driver.version;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        MISE_NODE_COMPILE = "0";

        # Point Playwright at the nixpkgs-patched browser bundle. These
        # browsers have proper RPATHs so they work without FHS/nix-ld. The
        # browser revisions are pinned to the Playwright release that
        # nixpkgs currently tracks (see playwrightVersion below).
        PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
        PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
        PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";

        packages = [
          pkgs.mise
        ];

        shellHook = ''
          echo "Node.js dev environment active."
          echo "Playwright browsers: nixpkgs playwright-driver ${playwrightVersion}"
          echo ""
          echo "If your project's npm 'playwright' package diverges from this"
          echo "version by more than a patch, browser tests may break due to"
          echo "protocol mismatches. Align the npm version, or 'nix flake update'"
          echo "this flake to bring nixpkgs forward."
        '';
      };
    };
}

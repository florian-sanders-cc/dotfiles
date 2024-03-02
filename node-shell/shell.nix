{
  pkgs ? import <nixpkgs> {},
  nodeVersion ? "21.0.0",
  npmVersion ? "10.5.0",
  npmPackageHash ? "sha256-UUblNnFiTGcqjHR+0zxyohdc8oTx52YePCHLZGBxSlQ=",
  npmDepsHash ? "sha256-+PMb4LsrYLuISXIkJxqKuEmxjRGDv3zYD6XncVvOQ+k=",
}: 

pkgs.mkShell rec {
  name = "nodejs project";

  nodeBinary = pkgs.callPackage ./node-binary.nix { inherit nodeVersion; };
  # npmBinary = pkgs.callPackage ./npm-binary.nix { inherit npmVersion npmPackageHash npmDepsHash pkgs; };

  packages = [
    # npmBinary
    nodeBinary
  ];


  shellHook = ''
    npm set prefix $NPM_PREFIX/npm-$PACKAGE_NPM_VERSION
    PATH="$NPM_PREFIX/npm-$PACKAGE_NPM_VERSION/bin:$PATH";
    if [ "$(npm -v)" != ${npmVersion} ]
      then
        npm i -g npm@$PACKAGE_NPM_VERSION
    fi
  '';
}

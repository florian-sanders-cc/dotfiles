{
  pkgs ? import <nixpkgs> { },
  nodeVersion ? "21.0.0",
  npmVersion ? "10.5.0",
}:

pkgs.mkShell rec {
  name = "nodejs project";

  nodeBinary = pkgs.callPackage ./node-binary.nix { inherit nodeVersion; };

  packages = [
    nodeBinary
  ];

  shellHook =
    if npmVersion != "null" then
      ''
        npm set prefix $NPM_PREFIX/npm-$PACKAGE_NPM_VERSION
        PATH="$NPM_PREFIX/npm-$PACKAGE_NPM_VERSION/bin:$PATH";
        if [ "$(npm -v)" != ${npmVersion} ]
          then
            npm i -g npm@$PACKAGE_NPM_VERSION
        fi
      ''
    else
      '''';
}

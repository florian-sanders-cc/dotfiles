{
  description = "My NodeJS Version Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    name = "NodeJS Shell maker";
    nodeBinary =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        projectRoot = builtins.getEnv "PWD";
        manifest = builtins.readFile "${projectRoot}/package.json";
        manifestJson = builtins.fromJSON manifest;
        nodeVersion = manifestJson.volta.node;

      in with pkgs; stdenv.mkDerivation rec {
        name = "node";

        src = builtins.fetchurl "https://nodejs.org/dist/v${nodeVersion}/node-v${nodeVersion}-linux-x64.tar.xz";

        nativeBuildInputs = [
          autoPatchelfHook 
        ];

        buildInputs = [ stdenv.cc.cc.lib ];

        installPhase = ''
          mkdir -p $out
          cd $out
          tar -xvf $src --strip-components 1
        '';
    };

    devShells.x86_64-linux.default = 
      let 
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        projectRoot = builtins.getEnv "PWD";
        manifest = builtins.readFile "${projectRoot}/package.json";
        manifestJson = builtins.fromJSON manifest;
        npmVersion = manifestJson.volta.npm;

      in 
        pkgs.mkShell {
          name = "volta-node-shell";
          packages = [ self.nodeBinary ];

          shellHook = ''
            PACKAGE_NODE_VERSION=$(cat package.json | jq -r '.volta.node')
            PACKAGE_NPM_VERSION=$(cat package.json | jq -r '.volta.npm')
            CURRENT_NPM_VERSION=$(npm -v)
            CURRENT_NODE_VERSION=$(node -v)
            echo $CURRENT_NPM_VERSION $PACKAGE_NPM_VERSION

            if [ "v$PACKAGE_NODE_VERSION" != "$CURRENT_NODE_VERSION" ]
            then
              echo 'not equals'
              nix flake update ~/.config/nixos-config/node-flake
            fi

            if [ "$PACKAGE_NPM_VERSION" != "$CURRENT_NPM_VERSION" ]
            then
              npm set prefix $NPM_PREFIX
              npm i -g npm@$PACKAGE_NPM_VERSION
              PATH="$NPM_PREFIX/bin:$PATH";
            fi
          '';
        };
  };
}

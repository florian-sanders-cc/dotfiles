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

        in 
          pkgs.mkShell {
            name = "volta-node-shell";
            packages = [ self.nodeBinary ];
          };
  };
}

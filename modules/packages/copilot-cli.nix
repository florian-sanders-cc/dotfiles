{ pkgs, ... }:

pkgs.buildNpmPackage rec {
  pname = "copilot-cli";
  version = "0.0.327";
  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@github/copilot/-/copilot-${version}.tgz";
    sha256 = "1i5c7r56awc58yax7pjfk06p3mclbzy26nm5ldjf8rnyzzjs5vm9";
  };
  buildInputs = [ pkgs.nodejs_22 ];
  npmDepsHash = "sha256-zncuZlawjxoA08vyGnmHFVYGvXxgBrAtdeFAonzI90Y="; # Placeholder hash, replace after first build
  patchedLock = ./deps/copilot-package-lock.json;
  postPatch = ''
    cp -v ${patchedLock} ./package-lock.json
  '';
  dontNpmBuild = true;
  meta = with pkgs.lib; {
    description = "GitHub Copilot CLI brings the power of Copilot coding agent directly to your terminal.";
    homepage = "https://github.com/github/copilot-cli";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}

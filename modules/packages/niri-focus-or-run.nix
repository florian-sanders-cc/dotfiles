{
  lib,
  fetchFromGitHub,
  rustPlatform,
  ...
}:

rustPlatform.buildRustPackage {
  pname = "niri-focus-or-run";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "florian-sanders";
    repo = "niri-focus-or-run";
    rev = "73a46afcf582cdb9bd749e573757423b6ecd5b0a";
    hash = "sha256-VRc340RWAXd7HzACeEly33yV2ymaYaftZssBiB1+VcE=";
  };

  cargoHash = "sha256-KEecvN58gpvwQCrOWl/nPoN0E7cREeTE2fXqRhmj8zs=";

  meta = {
    description = "Make niri focus the next window matching the given program name. If no active windows exists, runs the program instead";
    homepage = "https://github.com/florian-sanders/niri-focus-or-run";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}

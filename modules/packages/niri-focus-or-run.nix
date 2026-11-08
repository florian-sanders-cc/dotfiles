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
    rev = "ed6cb76fed1c8bbe57bb33ff5af7b786b439e450";
    hash = "sha256-xbO3Sjg+T+hAxgSTchgOCBPJiNN2ZUOLbAUhr522JcA=";
  };

  cargoHash = "sha256-KEecvN58gpvwQCrOWl/nPoN0E7cREeTE2fXqRhmj8zs=";

  meta = {
    description = "Make niri focus the next window matching the given program name. If no active windows exists, runs the program instead";
    homepage = "https://github.com/florian-sanders/niri-focus-or-run";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}

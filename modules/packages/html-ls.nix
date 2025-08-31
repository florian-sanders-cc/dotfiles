{ lib
, fetchFromGitHub
, buildNpmPackage
}:

buildNpmPackage rec {
  pname = "html-ls";
  version = "4.10.5";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "vscode-langservers-extracted";
    rev = "v${version}";
    hash = "sha256-gy9bwH+m9ajHR6EvkR1+pisABQewz7rO5QguG4NOsWk=";
  };

  npmDepsHash = "sha256-/Af71mB/kD7zsZtyQfuOoPRSqnV+p6cY2BYlMB4VuUM=";

  # Don't run tests during build as they require additional setup
  dontNpmBuild = true;
  dontNpmTest = true;

  postInstall = ''
    # Copy the packages directory to the expected location
    cp -r packages $out/lib/node_modules/@zed-industries/vscode-langservers-extracted/
    
    # Create the html-ls binary by renaming from the original
    mv $out/bin/vscode-html-language-server $out/bin/html-ls
    
    # Keep the other language servers with their original names
    # (or create additional shorter aliases if needed)
  '';

  meta = with lib; {
    description = "HTML/CSS/JSON/ESLint language servers extracted from vscode";
    homepage = "https://github.com/zed-industries/vscode-langservers-extracted";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}


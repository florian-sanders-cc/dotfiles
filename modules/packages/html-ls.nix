{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "html-ls";
  version = "4.10.7";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "vscode-langservers-extracted";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

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

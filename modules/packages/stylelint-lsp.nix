{
  lib,
  stdenv,
  fetchurl,
  unzip,
  nodejs,
}:

stdenv.mkDerivation rec {
  pname = "stylelint-lsp";
  version = "1.5.3";

  src = fetchurl {
    url = "https://open-vsx.org/api/stylelint/vscode-stylelint/${version}/file/stylelint.vscode-stylelint-${version}.vsix";
    sha256 = "1bsia43dpxbx6nky1lybnf64lvn0qgsdwknvarqnkyihvqixnk5w";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip -q $src
  '';

  installPhase = ''
        mkdir -p $out/bin
        mkdir -p $out/lib/stylelint-lsp
        
        # Copy the extension files
        cp -r extension/* $out/lib/stylelint-lsp/
        
        # Create wrapper script
        cat > $out/bin/stylelint-lsp << EOF
    #!/bin/sh
    exec ${nodejs}/bin/node $out/lib/stylelint-lsp/dist/start-server.js --stdio "\$@"
    EOF
        
        chmod +x $out/bin/stylelint-lsp
  '';

  meta = with lib; {
    description = "Stylelint language server extracted from VSCode extension";
    homepage = "https://github.com/stylelint/vscode-stylelint";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}

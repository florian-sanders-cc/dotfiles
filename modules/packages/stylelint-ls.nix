{ lib
, stdenv
, fetchurl
, unzip
, nodejs
,
}:

stdenv.mkDerivation rec {
  pname = "stylelint-ls";
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
        mkdir -p $out/lib/stylelint-ls
        
        # Copy the extension files
        cp -r extension/* $out/lib/stylelint-ls/
        
        # Create wrapper script
        cat > $out/bin/stylelint-ls << EOF
    #!/usr/bin/env sh
    exec env node $out/lib/stylelint-ls/dist/start-server.js --stdio "\$@"
    EOF
        
        chmod +x $out/bin/stylelint-ls
  '';

  meta = with lib; {
    description = "Stylelint language server extracted from VSCode extension";
    homepage = "https://github.com/stylelint/vscode-stylelint";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}

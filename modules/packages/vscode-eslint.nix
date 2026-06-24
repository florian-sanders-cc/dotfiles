{
  lib,
  runCommandLocal,
  makeWrapper,
  nodejs,
  vscode-extensions,
}:

let
  ext = vscode-extensions.dbaeumer.vscode-eslint; # version 3.0.24, prebuilt marketplace VSIX
  server = "${ext}/share/vscode/extensions/dbaeumer.vscode-eslint/server/out/eslintServer.js";
in
runCommandLocal "vscode-eslint-${ext.version}"
  {
    nativeBuildInputs = [ makeWrapper ];
    meta = with lib; {
      description = "Official microsoft/vscode-eslint language server (wrapped node + eslintServer.js)";
      homepage = "https://github.com/microsoft/vscode-eslint";
      license = licenses.mit;
      platforms = platforms.all;
    };
  }
  ''
    mkdir -p $out/bin
    # Mirror Zed's launch: node --max-old-space-size=8192 eslintServer.js [--stdio]
    # `--stdio` is appended by each editor (languages.toml / eslint.lua), not here.
    makeWrapper ${nodejs}/bin/node $out/bin/vscode-eslint \
      --add-flags "--max-old-space-size=8192" \
      --add-flags "${server}"
  ''

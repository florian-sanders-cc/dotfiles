{
  pkgs,
  lib,
  wc-ls,
}:

let
  # Fetch the repository with the neovim extension
  src = pkgs.fetchFromGitHub {
    owner = "wc-toolkit";
    repo = "wc-language-server";
    rev = "add-neovim-extension";
    sha256 = "sha256-xCi4NjF+mJM4Fngl2uZM7rnUo35GgwVmw2Iq4AXYVXc=";
  };
in
pkgs.vimUtils.buildVimPlugin {
  pname = "wc-language-server-nvim";
  version = "2025-01-27";

  inherit src;

  # Only include the neovim plugin files from the monorepo
  postPatch = ''
    # Keep only the neovim plugin files
    rm -rf packages/vscode packages/jetbrains packages/wctools packages/language-server
    mv packages/neovim/* .
    rm -rf packages

    # Replace server path placeholder with actual wc-language-server binary
    if [ -f lua/wc_language_server/init.lua ]; then
      substituteInPlace lua/wc_language_server/init.lua \
        --replace-warn '"wc-language-server"' '"${wc-ls}/bin/wc-language-server"'
    fi
  '';

  meta = with lib; {
    description = "Neovim plugin for Web Components Language Server";
    homepage = "https://github.com/wc-toolkit/wc-language-server";
    license = licenses.mit;
    platforms = platforms.all;
    hydraPlatforms = [ ];
  };
}

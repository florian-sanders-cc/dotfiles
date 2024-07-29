{ vscode-utils, lib, ... }:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;

in 
buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-eslint";
    publisher = "dbaeumer";
    version = "2.4.2";
    sha256 = "sha256-eIjaiVQ7PNJUtOiZlM+lw6VmW07FbMWPtY7UoedWtbw=";
  };
  meta = {
    changelog = "https://marketplace.visualstudio.com/items/dbaeumer.vscode-eslint/changelog";
    description = "Integrates ESLint JavaScript into VS Code.";
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint";
    homepage = "https://github.com/Microsoft/vscode-eslint";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.datafoo ];
  };
}

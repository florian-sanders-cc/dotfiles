{ lib, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    package = pkgs.helix-editor-pkgs;

    settings = {
      theme = "kanagawa";
      editor = {
        completion-timeout = 50;
        mouse = false;
      };
      keys.normal = {
        "C-s" = ":w";
      };
      keys.insert = {
        "C-s" = ":w";
      };
    };

    extraPackages = with pkgs; [
      typescript
      nodePackages_latest.typescript-language-server
      lua-language-server
      nixd
      stylelint
      (callPackage ./stylelint-lsp.nix { })
      vscode-langservers-extracted
      nixpkgs-fmt
    ];

    languages = {
      language = [{
        name = "javascript";
        formatter = {
          command = "stylelint";
          args = [ "--fix" "--stdin" ];
        };
        language-servers = [ "typescript-language-server" "stylelint" ];
      }];
      language-server.typescript-language-server = {
        command = "${pkgs.nodePackages.typescript-language-server}/lib/node_modules/.bin/typescript-language-server";
        args = [ "--stdio" ];
        config = {
          hostInfo = "helix";
        };
      };
      language-server.stylelint = {
        command = "stylelint-lsp";
        args = [ "--stdio" ];
        config = {
          root_file = [
            ".stylelintrc"
            ".stylelintrc.cjs"
            ".stylelintrc.js"
            ".stylelintrc.json"
            ".stylelintrc.yaml"
            ".stylelintrc.yml"
            "stylelint.config.cjs"
            "stylelint.config.js"
          ];
          autoFixOnSave = true;
          autoFixOnFormat = true;
          cssInJs = true;
          customSyntax = "postcss-lit";
          validate = [
            "css"
            "less"
            "postcss"
          ];
        };
      };
    };
  };
  xdg.configFile."helix/runtime".source = ../../../dotfiles/helix/runtime;
}

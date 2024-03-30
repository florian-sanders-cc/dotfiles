{ lib, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    package = pkgs.helix-editor-pkgs;

    settings = {
      theme = "kanagawa";
      editor = {
        completion-timeout = 50;
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
      (callPackage ./stylelint-lsp.nix { })
      vscode-langservers-extracted
      nixpkgs-fmt
    ];

    languages = {
      language = [{
        name = "javascript";
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
      };
    };
  };
  xdg.configFile."helix/runtime".source = ../../../dotfiles/helix/runtime;
}

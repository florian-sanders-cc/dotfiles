{ lib, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    package = pkgs.helix-editor-pkgs;

    settings = {
      theme = "kanagawa";
      editor = {
        line-number = "relative";
        completion-timeout = 50;
        mouse = false;
        color-modes = true;
        indent-guides = {
          render = true;
          character = "╎";
          skip-levels = 1;
        };
      };
      keys.normal = {
        "C-s" = ":w";
        "C-m" = "save_selection";
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
      language = [
        {
          name = "javascript";
          language-servers = [ "typescript-language-server" "stylelint" "eslint" ];
          formatter = {
            command = "eslint";
            args = [ "--fix" ];
          };
        }

        {
          name = "nix";
          scope = "source.nix";
          injection-regex = "nix";
          file-types = [ "nix" ];
          shebangs = [ ];
          comment-token = "#";
          language-servers = [ "nixd" ];
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
      ];

      language-server.eslint = {
        command = "vscode-eslint-language-server";
        args = [ "--stdio" ];
        config = {
          format = true;
          options = {
            rulePaths = [ "/home/flo/Projects/clever-components/eslint-rules" ];
          };
          nodePath = "";
          onIgnoredFiles = "off";
          packageManager = "yarn";
          quiet = false;
          rulesCustomizations = [ ];
          run = "onType";
          useESLintClass = false;
          validate = "on";
          codeAction = {
            disableRuleComment = {
              enable = true;
              location = "separateLine";
            };
            showDocumentation = { enable = true; };
          };
          codeActionOnSave = {
            enable = true;
            mode = "fixAll";
          };
          experimental = { useFlatConfig = false; };
          problems = {
            shortenToSingleLine = false;
          };
          workingDirectory = {
            mode = "auto";
          };
          root_file = [
            ".eslintrc"
            ".eslintrc.js"
            ".eslintrc.cjs"
            ".eslintrc.yaml"
            ".eslintrc.yml"
            ".eslintrc.json"
            "eslint.config.js"
            "eslint.config.mjs"
            "eslint.config.cjs"
            "eslint.config.ts"
            "eslint.config.mts"
            "eslint.config.cts"
          ];
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

      language-server.nixd = {
        command = "nixd";
      };
    };
  };
  xdg.configFile."helix/runtime".source = ../../../dotfiles/helix/runtime;
}

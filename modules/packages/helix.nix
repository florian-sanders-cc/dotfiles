{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    # package = pkgs.helix-nightly;

    settings = {
      theme = "kanagawa";
      editor = {
        auto-format = true;
        line-number = "relative";
        completion-timeout = 50;
        mouse = false;
        color-modes = true;
        true-color = true;
        cursorline = true;
        bufferline = "multiple";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          character = "⸽";
          render = true;
        };
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-name"
          ];
        };
        inline-diagnostics = {
          cursor-line = "error";
          other-lines = "disable";
        };
      };
      keys.normal = {
        "C-s" = ":w";
        "C-m" = "save_selection";
        A-x = "extend_to_line_bounds";
        X = [
          "extend_line_up"
          "extend_to_line_bounds"
        ];
        "g" = {
          "D" = [
            "hsplit"
            "jump_view_up"
            "goto_definition"
          ];
        };
      };
      keys.insert = {
        "C-s" = ":w";
        A-x = "extend_to_line_bounds";
        X = [
          "extend_line_up"
          "extend_to_line_bounds"
        ];
      };
    };

    extraPackages = with pkgs; [
      typescript
      vtsls
      lua-language-server
      nixd
      stylelint-lsp
      vscode-langservers-extracted
      nixfmt-rfc-style
      typescript-go
      wc-ls
    ];

    languages = {
      language = [
        {
          name = "typescript";
          language-servers = [
            "vtsls"
            "eslint"
          ];
        }
        {
          name = "javascript";
          language-servers = [
            {
              name = "vtsls";
            }
            "stylelint"
            "eslint"
          ];
          formatter = {
            command = "./node_modules/prettier/bin/prettier.cjs";
            args = [
              "--parser"
              "typescript"
            ];
          };
          auto-format = true;
        }

        {
          name = "nix";
          scope = "source.nix";
          injection-regex = "nix";
          file-types = [ "nix" ];
          shebangs = [ ];
          comment-token = "#";
          language-servers = [ "nixd" ];
          formatter = {
            command = "nixfmt";
            args = [ ];
          };
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
        {
          name = "html";
          language-servers = [
            "wc-language-server"
            "vscode-html-language-server"
          ];
        }
      ];

      language-server.tsgo = {
        command = "tsgo";
        args = [
          "--lsp"
          "--stdio"
        ];
      };

      language-server.vtsls = {
        command = "vtsls";
        args = [ "--stdio" ];
        required-root-patterns = [ "tsconfig.json" ];
        config = {
          vtsls = {
            enableMoveToFileCodeAction = true;
          };
          tsserver = {
            maxTsServerMemory = 8192;
          };
          experimental = {
            completion = {
              enableServerSideFuzzyMatch = true;
              entriesLimit = 50;
            };
          };
          typescript = {
            preferences = {
              importModuleSpecifier = "relative";
              includePackageJsonAutoImports = "off";
              useAliasesForRenames = false;
              format = {
                enable = false;
              };
            };
            suggest = {
              completeFunctionCalls = true;
            };
            updateImportsOnFileMove = {
              enabled = "always";
            };
          };
          javascript = {
            preferences = {
              importModuleSpecifier = "relative";
              includePackageJsonAutoImports = "off";
              useAliasesForRenames = false;
              format = {
                enable = false;
              };
            };
            suggest = {
              completeFunctionCalls = true;
            };
            updateImportsOnFileMove = {
              enabled = "always";
            };
          };
        };
      };

      language-server.eslint = {
        command = "vscode-eslint-language-server";
        args = [ "--stdio" ];
        config = {
          format = true;
          onIgnoredFiles = "off";
          quiet = false;
          run = "onType";
          useESLintClass = false;
          validate = "on";
          codeAction = {
            disableRuleComment = {
              enable = true;
              location = "separateLine";
            };
            showDocumentation = {
              enable = true;
            };
          };
          codeActionOnSave = {
            enable = true;
            mode = "fixAll";
          };
          experimental = {
            useFlatConfig = false;
          };
          problems = {
            shortenToSingleLine = false;
          };
          workingDirectory = {
            mode = "location";
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

      language-server.wc-language-server = {
        command = "wc-language-server";
        args = [ "--stdio" ];
      };
    };
  };
  xdg.configFile."helix/runtime".source = ../../dotfiles/helix/runtime;
}

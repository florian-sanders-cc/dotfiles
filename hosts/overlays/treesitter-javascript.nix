(final: prev: {
  vimPlugins = prev.vimPlugins
      // {
        nvim-treesitter-parsers = prev.vimUtils.buildVimPlugin {

          }
      javascript = {
        src =  prev.fetchFromGitHub {
          owner = "tree-sitter";
          repo = "tree-sitter-javascript";
          rev = "6d84193ae2395e54b699d9b7358bcf66cbcc19f5";
          hash = "sha256-LyhWCoUZ0tvdIXiW7jTpbYcdR98IFrYlBPiYRK+xw8c=";
        };
      };
      };
  });
})

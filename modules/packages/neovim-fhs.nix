{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (buildFHSEnv {
      name = "nvim";
      targetPkgs = pkgs: [
        neovim-unwrapped
        gcc
        clang
        cargo
        unzip
        fd
        ripgrep
        bat
        delta
        rustup
        gnumake
        gnutar
      ];
      runScript = "nvim";
    })
  ];

  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };

  # fix injection for CSS in JS with Lit (styled injection breaks comment strings)
  xdg.configFile."nvim/after/queries/ecma/injections.scm".text = ''
    ; extends
    (call_expression
      function: (identifier) @_name
      (#any-of? @_name "css" "keyframes")
      arguments: ((template_string) @injection.content
        (#offset! @injection.content 0 1 0 -1)
        (#set! injection.include-children)
        (#set! injection.language "css")))
  '';
}

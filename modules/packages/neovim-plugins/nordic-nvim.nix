{ pkgs, ... }:

pkgs.vimUtils.buildVimPlugin rec {
  pname = "nordic.nvim";
  version = "0.2.0";
  src = pkgs.fetchFromGitHub {
    owner = "AlexvZyl";
    repo = "nordic.nvim";
    rev = version;
    sha256 = "sha256-kjr4SsRbKfVgNjAFWybkRQ8/QDOPLm7lbysi6Gblpfg=";
  };
  meta.homepage = "https://github.com/AlexvZyl/nordic.nvim";
}

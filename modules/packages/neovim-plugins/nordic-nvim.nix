{ pkgs, ... }:

pkgs.vimUtils.buildVimPlugin {
  pname = "nordic.nvim";
  version = "2025-12-22";
  src = pkgs.fetchFromGitHub {
    owner = "AlexvZyl";
    repo = "nordic.nvim";
    rev = "082b61f583317cb529530c85466541d5442a2aae";
    sha256 = "sha256-1eOPlBmV9OK/YyV+wO5nel6n2GXMuLddV+66q3mY4Qg=";
  };
  meta.homepage = "https://github.com/AlexvZyl/nordic.nvim";
}

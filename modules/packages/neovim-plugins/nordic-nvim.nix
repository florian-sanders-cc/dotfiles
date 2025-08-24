{ pkgs, ... }:

pkgs.vimUtils.buildVimPlugin {
  pname = "nordic.nvim";
  version = "2025-05-15";
  src = pkgs.fetchFromGitHub {
    owner = "AlexvZyl";
    repo = "nordic.nvim";
    rev = "6afe957722fb1b0ec7ca5fbea5a651bcca55f3e1";
    sha256 = "sha256-NY4kjeq01sMTg1PZeVVa2Vle4KpLwWEv4y34cDQ6JMU=";
  };
  meta.homepage = "https://github.com/AlexvZyl/nordic.nvim";
  meta.hydraPlatforms = [ ];
}

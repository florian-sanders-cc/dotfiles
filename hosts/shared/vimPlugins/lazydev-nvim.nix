{ pkgs
, fetchFromGitHub
}:

pkgs.vimUtils.buildVimPlugin rec {
  pname = "lazydev.nvim";

  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "folke";
    repo = "lazydev.nvim";
    rev = "v${version}";
    hash = "sha256-Cyt63YQf+s0NpsQZi1FHuEq4gvnVcOsZxm/qPKRbigw=";
  };
}

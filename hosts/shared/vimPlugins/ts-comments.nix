{ pkgs
, fetchFromGitHub
}:

pkgs.vimUtils.buildVimPlugin rec {
  pname = "ts-comments.nvim";

  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "folke";
    repo = "ts-comments.nvim";
    rev = "v${version}";
    hash = "sha256-2WvNt5MrmtcMs2eiKSMW14pSFVgoSZM/L62YrjvSUt0=";
  };
}

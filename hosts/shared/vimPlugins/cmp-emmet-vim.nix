{ lib
, stdenv
, fetchFromGitHub
, pkgs
,
}:

pkgs.vimUtils.buildVimPlugin {
  pname = "cmp-emmet-vim";
  version = "2023-05-06";

  src = fetchFromGitHub {
    owner = "dcampos";
    repo = "cmp-emmet-vim";
    rev = "0fb9a6eae7c1a56b7f460a80a09a402a57a7cc99";
    hash = "sha256-w37CmFNh33ACmWgYU2kM7MbuRdwi7URVquJgjRPE1gA=";
  };

  meta = {
    description = "emmet-vim completion source for nvim-cmp.";
    homepage = "https://github.com/dcampos/cmp-emmet-vim";
  };
}


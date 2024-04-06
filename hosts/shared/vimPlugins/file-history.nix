{ lib
, stdenv
, fetchFromGitHub
, pkgs
,
}:

pkgs.vimUtils.buildVimPlugin {
  pname = "telescope-file-history.nvim";
  version = "2023-12-19";

  src = fetchFromGitHub {
    owner = "dawsers";
    repo = "telescope-file-history.nvim";
    rev = "0f8dab459f7b76a95d77d2f1d9b16446a97af62e";
    hash = "sha256-TgRixprsHRTH9lr2AEUh7xIX8w9JquOzFJV4K8OPJI8=";
  };

  meta = {
    description = "File history backup for Neovim";
    homepage = "https://github.com/dawsers/telescope-file-history.nvim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}


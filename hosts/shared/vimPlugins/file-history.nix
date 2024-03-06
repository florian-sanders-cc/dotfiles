{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "telescope-file-history.nvim";
  version = "2023-12-19";

  src = fetchFromGitHub {
    owner = "dawsers";
    repo = "telescope-file-history.nvim";
    rev = "0f8dab459f7b76a95d77d2f1d9b16446a97af62e";
    hash = "sha256-TgRixprsHRTH9lr2AEUh7xIX8w9JquOzFJV4K8OPJI8=";
  };

  telescopeFileHistory = pkgs.vimUtils.buildVimPlugin {
    pname = finalAttrs.pname;
    version = finalAttrs.version;
    src = finalAttrs.src;
  };
  
  installPhase = ''
    cp -r ${finalAttrs.telescopeFileHistory} $out
  '';

  meta = {
    description = "File history backup for Neovim";
    homepage = "https://github.com/dawsers/telescope-file-history.nvim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [  ];
  };
})


{
  lib,
  stdenv,
  fetchFromGitHub,
  pkgs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "transparent.nvim";
  version = "2023-11-12";

  src = fetchFromGitHub {
    owner = "xiyaowong";
    repo = "transparent.nvim";
    rev = "fd35a46f4b7c1b244249266bdcb2da3814f01724";
    hash = "sha256-wT+7rmp08r0XYGp+MhjJX8dsFTar8+nf10CV9OdkOSk=";
  };

  transparentNvimBuilt = pkgs.vimUtils.buildVimPlugin {
    pname = finalAttrs.pname;
    version = finalAttrs.version;
    src = finalAttrs.src;
  };
  
  installPhase = ''
    cp -r ${finalAttrs.transparentNvimBuilt} $out
  '';

  meta = {
    description = "File history backup for Neovim";
    homepage = "https://github.com/xiayowong/transparent.nvim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [  ];
  };
})


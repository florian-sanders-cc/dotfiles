{ pkgs, ... }:

pkgs.vimUtils.buildVimPlugin {
  pname = "agentic.nvim";
  version = "2026-02-25";
  src = pkgs.fetchFromGitHub {
    owner = "carlos-algms";
    repo = "agentic.nvim";
    rev = "1f26e5ad9418b4df4a196fea3ff8aa0283e2c048";
    sha256 = "sha256-V9rbJzeXA4E5W/1CrGjuDdZz/1gb9aHaq4gs6z8Tivc=";
  };
  propagatedBuildInputs = [ pkgs.opencode ];
  doCheck = false;
  meta.homepage = "https://github.com/carlos-algms/agentic.nvim";
}

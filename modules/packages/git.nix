{ config, lib, ... }:

{
  # TODO sign key etc.
  options.user.email = with lib; mkOption {
    type = types.str;
    default = "florian.sanders@clever-cloud.com";
  };

  config = {
    programs.git = {
      enable = true;
      userEmail = config.user.email;
      userName = "Florian Sanders";
      extraConfig = {
        core.editor = "nvim";
        core.excludesFile = "~/.gitignore";
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
        commit.gpgsign = false;
        signing.key = "";
        gpg.program = "gpg2";
        tag.gpgsign = true;
      };
    };
    home.file.".gitignore".source = ../../dotfiles/gitignore;
  };
}

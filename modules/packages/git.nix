{ config, lib, ... }:

{
  # TODO sign key etc.
  options.user.email =
    with lib;
    mkOption {
      type = types.str;
    };

  config = {
    programs.git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
          excludesFile = "~/.gitignore";
        };
        user = {
          name = "Florian Sanders";
          email = config.user.email;
          signingKey = "E94DAA3CD0C7151B";
        };
        commit.gpgSign = true;
        tag.gpgSign = true;
        gpg.program = "${config.programs.gpg.package}/bin/gpg2";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };
    home.file.".gitignore".source = ../../dotfiles/gitignore;
  };
}

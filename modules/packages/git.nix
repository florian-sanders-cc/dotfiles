{ config, lib, ... }:

{
  # TODO sign key etc.
  options.user.email =
    with lib;
    mkOption {
      type = types.str;
    };
  options.user.name =
    with lib;
    mkOption {
      type = types.str;
    };

  config = {
    programs.git = {
      enable = true;
      extraConfig = {
        diff.algorithm = "histogram";
        diff.tool = "difftastic";
        difftool = {
          prompt = false;
          difftastic = {
            cmd = "difft \"$LOCAL\" \"$REMOTE\"";
          };
        };
        transfer.fsckobjects = true;
        fetch.fsckobjects = true;
        receive.fsckObjects = true;
        pager = {
          difftool = true;
        };
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
          excludesFile = "~/.gitignore";
        };
        user = {
          name = "Florian Sanders";
          email = config.user.email;
          signingKey = lib.mkMerge [
            (lib.mkIf (config.user.name == "flo-pro") "E94DAA3CD0C7151B")
            (lib.mkIf (config.user.name == "flo-perso") "32343690B0FD8FBE")
          ];
        };
        commit.gpgSign = true;
        commit.verbose = true;
        gpg.program = "${config.programs.gpg.package}/bin/gpg2";
        merge.conflictstyle = "zdiff3";
        pull.rebase = true;
        push.autoSetupRemote = true;
        tag.gpgSign = true;
      };
    };
    home.file.".gitignore".source = ../../dotfiles/gitignore;
  };
}

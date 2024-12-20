{
  config,
  lib,
  currentUser,
  ...
}:

{
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
      user =
        {
          name = "Florian Sanders";
          email = currentUser.email;
        }
        // lib.optionalAttrs (builtins.hasAttr "signingKey" currentUser) {
          signingKey = currentUser.signingKey;
        };
      commit.gpgSign = lib.mkIf (builtins.hasAttr "signingKey" currentUser) true;
      commit.verbose = true;
      gpg.program = "${config.programs.gpg.package}/bin/gpg2";
      merge.conflictstyle = "zdiff3";
      pull.rebase = true;
      push.autoSetupRemote = true;
      tag.gpgSign = lib.mkIf (builtins.hasAttr "signingKey" currentUser) true;
    };
  };
  home.file.".gitignore".source = ../../dotfiles/gitignore;
}

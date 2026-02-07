{
  config,
  lib,
  currentUser,
  ...
}:

{
  programs.git = {
    enable = true;
    settings = {
      diff.algorithm = "histogram";
      diff.tool = "codediff";
      difftool = {
        prompt = false;
        codediff = {
          cmd = ''nvim "$LOCAL" "$REMOTE" +"CodeDiff file $LOCAL $REMOTE"'';
        };
      };
      merge.tool = "codediff";
      mergetool = {
        codediff = {
          cmd = ''nvim "$MERGED" -c "CodeDiff merge \"$MERGED\""'';
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

  programs.jujutsu = {
    enable = true;
    settings = {
      name = "Florian Sanders";
      email = currentUser.email;
      signing = {
        behavior = "own";
        backend = "gpg";
      }
      // lib.optionalAttrs (builtins.hasAttr "signingKey" currentUser) {
        key = currentUser.signingKey;
      };
    };
  };
}

{
  config,
  lib,
  currentUser,
  ...
}:

let
  specs = import ../../config-specifications.nix;
in

{
  programs.git = {
    enable = true;
    signing.format = "openpgp";
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
    settings =
      let
        jjSettings = {
          user = {
            name = "Florian Sanders";
            email = currentUser.email;
          };
          signing = {
            behavior = "own";
            backend = "gpg";
          };
        };
      in
      jjSettings
      // lib.optionalAttrs (builtins.hasAttr "signingKey" currentUser) {
        signing.key = currentUser.signingKey;
      }
      // lib.optionalAttrs (currentUser.name == specs.users.pro.name) {
        # ui = {
        #   diff-editor = [
        #     "nvim"
        #     "-c"
        #     "DiffEditor ''$left $right $output"
        #   ];
        # };
      }
      // {
        ui = {
          diff-formatter = ":git";
          # hunk.nvim handles diff editing (jj split -i, jj diffedit, jj squash -i)
          # diff-editor = [
          #   "nvim"
          #   "-c"
          #   "DiffEditor $left $right $output"
          # ];
          # vscodium 3-way merge editor handles conflict resolution (jj resolve)
          merge-editor = "vscodium";
        };
        # "merge-tools".nvimdiff = {
        #   program = "nvim";
        #   # 4-pane layout: left/base/right across top, output on bottom
        #   # $output is pre-populated with conflict markers; edit it to resolve
        #   merge-args = [
        #     "-f"
        #     "-d"
        #     "$output"
        #     "-M"
        #     "$left"
        #     "$base"
        #     "$right"
        #     "-c"
        #     "wincmd J"
        #     "-c"
        #     "set modifiable"
        #     "-c"
        #     "set write"
        #   ];
        #   merge-tool-edits-conflict-markers = true;
        # };
      };
  };
}

{
    programs.git = {
        enable = true;
        userEmail = "florian.sanders@clever-cloud.com";
        userName = "Florian Sanders";
        extraConfig = {
          core.editor = "nvim";
          core.excludesFile = "~/.gitignore";
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
          commit.gpgsign = true;
          signing.key = "22B2EAD482730FC2";
          gpg.program = "gpg2";
          tag.gpgsign = true;
        };
    };
    home.file.".gitignore".source = ../../../dotfiles/gitignore;
}

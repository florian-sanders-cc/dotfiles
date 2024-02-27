{
    programs.git = {
        enable = true;
        userEmail = "sanders.florian@gmail.com";
        userName = "Florian Sanders";
        extraConfig = {
          core.editor = "nvim";
          core.excludesFile = "~/.gitignore";
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
        };
    };
    home.file.".gitignore".source = ../../../dotfiles/gitignore;
}

{ ... }:

{
  programs.fish = {
    enable = true;
    loginShellInit = ''
      # Remove welcome message
      function fish_greeting; end
    '';
    interactiveShellInit =
      # fish
      ''
          function fish_greeting; end
        # Aliases
            alias g='git'
        #compdef g=git
            alias gst='git status'
        #compdef _git gst=git-status
            alias gd='git diff'
        #compdef _git gd=git-diff
            alias gdc='git diff --cached'
        #compdef _git gdc=git-diff
            alias gl='git pull'
        #compdef _git gl=git-pull
            alias gup='git pull --rebase'
        #compdef _git gup=git-fetch
            alias gp='git push'
            alias gpf='git push --force-with-lease'
        #compdef _git gp=git-push
            alias gd='git diff'

            function gdv
                git diff -w $argv | view -
            end

        #compdef _git gdv=git-diff
            alias gc='git commit -v'
        #compdef _git gc=git-commit
            alias gc!='git commit -v --amend'
        #compdef _git gc!=git-commit
            alias gca='git commit -v -a'
        #compdef _git gc=git-commit
            alias gca!='git commit -v -a --amend'
        #compdef _git gca!=git-commit
            alias gcmsg='git commit -m'
        #compdef _git gcmsg=git-commit
            alias gsw='git switch'
        #compdef _git gco=git-checkout
            alias gswm='git switch master'
            alias gr='git remote'
        #compdef _git gr=git-remote
            alias grv='git remote -v'
        #compdef _git grv=git-remote
            alias grmv='git remote rename'
        #compdef _git grmv=git-remote
            alias grrm='git remote remove'
        #compdef _git grrm=git-remote
            alias grset='git remote set-url'
        #compdef _git grset=git-remote
            alias grup='git remote update'
        #compdef _git grset=git-remote
            alias grbi='git rebase -i'
        #compdef _git grbi=git-rebase
            alias grbc='git rebase --continue'
        #compdef _git grbc=git-rebase
            alias grba='git rebase --abort'
        #compdef _git grba=git-rebase
            alias gb='git branch'
        #compdef _git gb=git-branch
            alias gba='git branch -a'
        #compdef _git gba=git-branch
            alias gcount='git shortlog -sn'
        #compdef gcount=git
            alias gcl='git config --list'
            alias gcp='git cherry-pick'
        #compdef _git gcp=git-cherry-pick
            alias glg='git log --stat --max-count=10'
        #compdef _git glg=git-log
            alias glgg='git log --graph --max-count=10'
        #compdef _git glgg=git-log
            alias glgga='git log --graph --decorate --all'
        #compdef _git glgga=git-log
            alias glo='git log --oneline'
            alias glog='git log --oneline --decorate --graph'
        #compdef _git glo=git-log
            alias gss='git status -s'
        #compdef _git gss=git-status
            alias ga='git add'
            alias gaa='git add --all'
        #compdef _git ga=git-add
            alias gm='git merge'
        #compdef _git gm=git-merge
            alias grh='git reset --soft'
            alias grhh='git reset --hard'
            alias gclean='git reset --hard; git clean'
            alias gwc='git whatchanged -p --abbrev-commit --pretty=medium'
            alias gbclean='git branch --merged | grep -v "main\|master\|develop\*" | xargs git branch -D'

        #remove the gf alias
        #alias gf='git ls-files | grep'

            alias gpoat='git push origin --all; and git push origin --tags'
            alias gmt='git mergetool --no-prompt'
        #compdef _git gm=git-mergetool

            alias gg='git gui citool'
            alias gga='git gui citool --amend'
            alias gk='gitk --all --branches'

            alias gsts='git stash show --text'
            alias gsta='git stash'
            alias gstp='git stash pop'
            alias gstd='git stash drop'

        # Will cd into the top of the current repository
        # or submodule.
            alias grt='cd (git rev-parse --show-toplevel; or echo ".")'

        # Git and svn mix
            alias git-svn-dcommit-push='git svn dcommit; and git push github master:svntrunk'
        #compdef git-svn-dcommit-push=git

            alias gsr='git svn rebase'
            alias gsd='git svn dcommit'
        #
        # Will return the current branch name
        # Usage example: git pull origin $(current_branch)
        #
            function current_branch
                set ref (git symbolic-ref HEAD 2> /dev/null); or set ref (git rev-parse --short HEAD 2> /dev/null); or return
                echo ref | sed s-refs/heads--
            end

            function current_repository
                set ref (git symbolic-ref HEAD 2> /dev/null); or set ref (git rev-parse --short HEAD 2> /dev/null); or return
                echo (git remote -v | cut -d':' -f 2)
            end

        # these aliases take advantage of the previous function
            alias ggpull='git pull origin (current_branch)'
        #compdef ggpull=git
            alias ggpur='git pull --rebase origin (current_branch)'
        #compdef ggpur=git
            alias ggpush='git push origin (current_branch)'
        #compdef ggpush=git
            alias ggpnp='git pull origin (current_branch); and git push origin (current_branch)'
        #compdef ggpnp=git

        # Pretty log messages
            function _git_log_prettily
                if ! [ -z $1 ]
                    then
                    git log --pretty=$1
                end
            end

            alias glp="_git_log_prettily"
        #compdef _git glp=git-log

        # Work In Progress (wip)
        # These features allow to pause a branch development and switch to another one (wip)
        # When you want to go back to work, just unwip it
        #
        # This function return a warning if the current branch is a wip
            function work_in_progress
                if git log -n 1 | grep -q -c wip
                    then
                    echo "WIP!!"
                end
            end

        # these alias commit and uncomit wip branches
            alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
            alias gunwip='git log -n 1 | grep -q -c wip; and git reset HEAD~1'

            function gcpr
                git fetch origin pull/$argv/head:pr-$argv
                git checkout pr-$argv
            end
          function y
              set tmp (mktemp -t "yazi-cwd.XXXXXX")
              yazi $argv --cwd-file="$tmp"
              if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
                  builtin cd -- "$cwd"
              end
              rm -f -- "$tmp"
          end

          function auto_start_zellij
              if test "$TERM" = "alacritty"
                or test "$TERM" = "foot" 
                  if not set -q ZELLIJ
                      if command -v zellij > /dev/null
                          exec zellij
                      end
                  end
              end
          end

          auto_start_zellij

          # Alt-H: Run current command with --help, then restore command
          function __fish_help_command
              set -l cmd (commandline)
              if test -n "$cmd"
                  commandline -r ""
                  echo
                  eval $cmd --help
                  commandline -r $cmd
                  commandline -f repaint
              end
          end
          bind -M insert \eh __fish_help_command
          bind -M default \eh __fish_help_command
      '';
  };
  xdg.configFile."fish/completions/clever.fish".source = ../../dotfiles/fish/completions/clever.fish;
}

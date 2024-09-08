{ ... }:

{
  programs.zsh = {
    enable = false;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    history = {
      size = 10000;
      path = "$HOME/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    initExtra = ''
      eval "$(direnv hook zsh)"
      if [[ $(ps --no-header -p $PPID -o comm) =~ '^alacritty$' ]]; then
              for wid in $(xdotool search --pid $PPID); do
                  xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $wid; done
      fi
    '';
  };
}

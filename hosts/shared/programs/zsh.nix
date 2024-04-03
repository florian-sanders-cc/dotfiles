{ config
, ...
}:

{
  programs.zsh = rec {
    enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    shellAliases = {
      ll = "ls -l -a";
      upd-gnome = "sudo nix flake update '${config.home.homeDirectory}/.config/nixos-config/' && sudo nixos-rebuild switch --upgrade --flake '${config.home.homeDirectory}/.config/nixos-config#laptop-gnome'";
      upd-plasma = "sudo nix flake update '${config.home.homeDirectory}/.config/nixos-config/' && sudo nixos-rebuild switch --upgrade --flake '${config.home.homeDirectory}/.config/nixos-config#laptop-plasma'";
      upd-hypr = "sudo nix flake update '${config.home.homeDirectory}/.config/nixos-config' && sudo nixos-rebuild switch --upgrade --flake '${config.home.homeDirectory}/.config/nixos-config#laptop-hypr'";
      nn = "cd ${config.home.homeDirectory}/Notes";
      SN = "s3cmd -c ${config.home.homeDirectory}/s3cfgs/flo-clever.s3cfg sync --delete-removed ${config.home.homeDirectory}/Notes/ s3://flo-clever-notes";
      SP = "s3cmd -c ${config.home.homeDirectory}/s3cfgs/flo-clever.s3cfg sync --delete-removed --exclude-from ${config.home.homeDirectory}/Projects/.s3ignore ${config.home.homeDirectory}/Projects s3://flo-projects-backup";
      rt = "random-labels Hubert Mathieu Florian Bob Pierre Hélène --clipboard";
      clean = "sudo nix-collect-garbage -d && nix-collect-garbage";
      nxcfg = "cd ${config.home.homeDirectory}/.config/nixos-config";
      ww = "cd ${config.home.homeDirectory}/Projects/";
      setnode = "cat ${config.home.homeDirectory}/.config/nixos-config/node-shell/.envrc-example >> .envrc && direnv allow";
    };
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
    '';
  };
}

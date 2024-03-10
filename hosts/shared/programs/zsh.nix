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
      upd-gnome = "sudo nix flake update '${config.home.homeDirectory}/.config/nixos-config/' && sudo nixos-rebuild switch --upgrade --flake '${config.home.homeDirectory}/.config/nixos-config/.#laptop-gnome'";
      upd-hypr = "sudo nix flake update '${config.home.homeDirectory}/.config/nixos-config' && sudo nixos-rebuild switch --upgrade --flake '${config.home.homeDirectory}/.config/nixos-config#laptop-hypr'";
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

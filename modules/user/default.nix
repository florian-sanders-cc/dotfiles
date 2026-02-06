{
  pkgs,
  config,
  home-manager,
  currentUser,
  ...
}:

let
  lib = pkgs.lib;
  shellAliases = import ./shell-aliases.nix { homeDirectory = currentUser.homeDirectory; };
  specs = import ../../config-specifications.nix;

in
{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  home-manager.extraSpecialArgs = {
    inherit currentUser;
  };
  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users."${currentUser.name}" = rec {

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "${currentUser.name}";
    home.homeDirectory = currentUser.homeDirectory;

    nix = {
      settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    home.shellAliases = lib.mkMerge [
      shellAliases.commonAliases
      (lib.mkIf (currentUser.name == specs.users.pro.name) shellAliases.proAliases)
      (lib.mkIf (currentUser.name == specs.users.perso.name) shellAliases.persoAliases)
      (lib.mkIf (
        currentUser.name == specs.users.perso-workstation.name
      ) shellAliases.persoWorkstationAliases)
    ];

    # config for nix CLI (allowUnfree for nix-shell -p command for instance)
    xdg.configFile."nixpkgs" = {
      source = ../../dotfiles/nixpkgs;
      recursive = true;
    };

    home.file."Projects/.s3ignore".source = ../../dotfiles/.s3ignore;

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = [ "zed.desktop" ];
        "text/markdown" = [ "zed.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "text/x-csrc" = [ "zed.desktop" ];
        "text/x-chdr" = [ "zed.desktop" ];
        "text/x-c++src" = [ "zed.desktop" ];
        "text/x-c++hdr" = [ "zed.desktop" ];
        "text/x-python" = [ "zed.desktop" ];
        "text/x-java" = [ "zed.desktop" ];
        "text/javascript" = [ "zed.desktop" ];
        "text/css" = [ "zed.desktop" ];
        "text/xml" = [ "zed.desktop" ];
        "text/x-shellscript" = [ "zed.desktop" ];
        "application/x-shellscript" = [ "zed.desktop" ];
        "application/json" = [ "zed.desktop" ];
        "application/x-yaml" = [ "zed.desktop" ];
        "application/x-php" = [ "zed.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "application/x-extension-htm" = [ "firefox.desktop" ];
        "application/x-extension-html" = [ "firefox.desktop" ];
        "application/x-extension-shtml" = [ "firefox.desktop" ];
        "application/xhtml+xml" = [ "firefox.desktop" ];
        "application/x-extension-xhtml" = [ "firefox.desktop" ];
        "application/x-extension-xht" = [ "firefox.desktop" ];
        "image/jpeg" = [ "firefox.desktop" ];
        "image/png" = [ "firefox.desktop" ];
        "image/gif" = [ "firefox.desktop" ];
        "image/webp" = [ "firefox.desktop" ];
        "image/tiff" = [ "firefox.desktop" ];
        "image/bmp" = [ "firefox.desktop" ];
        "application/pdf" = [ "firefox.desktop" ];
        "application/xml" = [ "zed.desktop" ];
        "application/toml" = [ "zed.desktop" ];
        "text/csv" = [ "zed.desktop" ];
        "text/x-sql" = [ "zed.desktop" ];
        "text/x-rust" = [ "zed.desktop" ];
        "text/x-go" = [ "zed.desktop" ];
        "video/mp4" = [ "vlc.desktop" ];
        "video/x-matroska" = [ "vlc.desktop" ];
        "video/quicktime" = [ "vlc.desktop" ];
        "audio/mpeg" = [ "vlc.desktop" ];
        "audio/x-wav" = [ "vlc.desktop" ];
        "audio/ogg" = [ "vlc.desktop" ];
        "inode/directory" = [ "yazi-kitty.desktop" ];
        "x-directory/normal" = [ "yazi-kitty.desktop" ];
        "x-scheme-handler/terminal" = [ "kitty.desktop" ];
      };
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "23.11";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    home.sessionVariables = {
      HOME = home.homeDirectory;
      NPM_PREFIX = "${home.homeDirectory}/.npm-packages";
      PATH = "${home.homeDirectory}/.npm-packages/bin:$PATH";
      NIXOS_OZONE_WL = "1";
      TERMINAL = "kitty";
    };
  };

  users.defaultUserShell = pkgs.fish;

  users.users."${currentUser.name}" = {
    isNormalUser = true;
    description = "flo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
    shell = pkgs.fish;
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}

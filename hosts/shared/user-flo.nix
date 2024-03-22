{ pkgs, ... }:

{
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.flo = {
        isNormalUser = true;
        description = "flo";
        extraGroups = [ "networkmanager" "wheel" ];
    };

    programs.zsh.enable = true;

    services.httpd.enable = true;
    services.httpd.adminAddr = "webmaster@example.org";
    services.httpd.enablePHP = true; # oof... not a great idea in my opinion

    services.httpd.virtualHosts."example.org" = {
        documentRoot = "/home/flo/test";
    };

    services.mysql.enable = true;
    services.mysql.package = pkgs.mariadb;
    
    users.defaultUserShell = pkgs.zsh;
}
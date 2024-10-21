{ pkgs, config, ... }:

{
  # move to php?
  services.httpd.enable = true;
  services.httpd.adminAddr = "webmaster@example.org";
  services.httpd.enablePHP = true; # oof... not a great idea in my opinion

  # TODO: remove
  # services.httpd.virtualHosts."example.org" = {
  #   documentRoot = "${config.user.homeDirectory}/test";
  # };

  # move to db?
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
}

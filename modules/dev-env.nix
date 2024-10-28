{ pkgs, config, ... }:

{
  services.httpd.enable = false;
  services.httpd.adminAddr = "webmaster@example.org";
  services.httpd.enablePHP = false;

  # TODO: remove
  # services.httpd.virtualHosts."yahoo.com" = {
  #   documentRoot = "${config.user.homeDirectory}/test";
  # };

  # move to db?
  services.mysql.enable = false;
  services.mysql.package = pkgs.mariadb;

  services.ollama = {
    enable = false;
    acceleration = "cuda";
  };
}

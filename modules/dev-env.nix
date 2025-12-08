{
  pkgs,
  ...
}:

{
  services.httpd.enable = false;
  services.httpd.adminAddr = "webmaster@example.org";
  services.httpd.enablePHP = false;

  # move to db?
  services.mysql.enable = false;
  services.mysql.package = pkgs.mariadb;

  services.ollama = {
    enable = false;
    package = pkgs.ollama-cuda;
  };
}

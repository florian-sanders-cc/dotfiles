{ lib, config, ... }:

let
  specs = import ../config-specifications.nix;
  userNames = import ../utils/get-user-info.nix { users = specs.users; key = "name"; };
  userEmails = import ../utils/get-user-info.nix { users = specs.users; key = "email"; };

in
{
  imports = [
    ./hardware
    ./system-config
    ./user
    ./desktop-env
    ./packages
    ./security.nix
  ];

  # TODO: options & default.nix within hardware
  options = {
    user = with lib; {
      name = mkOption {
        description = "User name";
        type = types.enum userNames;
        default = specs.users.pro.name;
      };

      # TODO: compute this
      email = mkOption
        {
          type = types.enum userEmails;
          default = specs.users.pro.email;
        };

      # TODO: clean this, there are simpler & cleaner solutions
      # + it should be a path
      homeDirectory = mkOption
        {
          type = types.str;
          default = "/home/${config.user.name}";
        };
    };
    desktop = with lib; mkOption
      {
        description = "Desktop environment to set";
        type = types.enum (builtins.attrNames specs.desktops);
        default = "plasma";
      };
  };
}

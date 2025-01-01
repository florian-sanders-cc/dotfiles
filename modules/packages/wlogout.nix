{ pkgs, ... }:

{
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "swaylock -k";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "logout";
        action = "niri msg action quit";
        text = "Logout";
        keybind = "e";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];
    style = ''
      * {
          background-image: none;
          box-shadow: none;
      }

      window {
          background-color: rgba(12, 12, 12, 0.9);
      }

      button {
          border-radius: 0;
          border-color: black;
          text-decoration-color: #ffffff;
          color: #ffffff;
          background-color: #1e1e1e;
          border-style: solid;
          border-width: 1px;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
      }

      button:focus,
      button:active,
      button:hover {
          background-color: #3700b3;
          outline-style: none;
      }

      #lock {
          background-image: image(url("${pkgs.wallpapers}/icons/lock.png"), url("./icons/lock.png"));
      }

      #logout {
          background-image: image(
              url("${pkgs.wallpapers}/assets/logout.svg"),
              url("${pkgs.wallpapers}/icons/logout.png")
          );
      }

      #suspend {
          background-image: image(
              url("${pkgs.wallpapers}/assets/suspend.svg"),
              url("${pkgs.wallpapers}/icons/suspend.png")
          );
      }

      #hibernate {
          background-image: image(
              url("${pkgs.wallpapers}/assets/hibernate.svg"),
              url("${pkgs.wallpapers}/icons/hibernate.png")
          );
      }

      #shutdown {
          background-image: image(
              url("${pkgs.wallpapers}/assets/shutdown.svg"),
              url("${pkgs.wallpapers}/icons/shutdown.png")
          );
      }

      #reboot {
          background-image: image(
              url("${pkgs.wallpapers}/assets/reboot.svg"),
              url("${pkgs.wallpapers}/icons/reboot.png")
          );
      }
    '';
  };
}

# modules/desktop/wlogout.nix
#
# wlogout - Wayland logout/power menu
# Catppuccin Mocha themed
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    programs.wlogout = {
      enable = true;
      layout = [
        {
          label = "lock";
          action = "swaylock -f";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "logout";
          action = "niri msg action quit";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
      ];
      style = ''
        * {
          background-image: none;
          font-family: "JetBrainsMono Nerd Font";
        }
        window {
          background-color: rgba(30, 30, 46, 0.85);
        }
        button {
          color: #cdd6f4;
          background-color: #313244;
          border: 2px solid #45475a;
          border-radius: 16px;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          margin: 10px;
        }
        button:focus, button:active, button:hover {
          background-color: #45475a;
          border-color: #89b4fa;
          outline-style: none;
        }
        #lock {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"));
        }
        #logout {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"));
        }
        #reboot {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"));
        }
        #shutdown {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"));
        }
      '';
    };
  };
}

# modules/desktop/waybar.nix
#
# Waybar - Wayland status bar (niri-compatible)
# Theme: Catppuccin Mocha
{
  flake.modules.homeManager.desktop = {
    programs.waybar = {
      enable = true;

      settings.mainBar = {
        layer = "top";
        position = "top";
        spacing = 4;

        modules-left = ["niri/workspaces"];
        modules-center = ["clock"];
        modules-right = ["mpris" "cpu" "memory" "pulseaudio" "tray"];

        "niri/workspaces" = {
          format = "{index}";
        };

        clock = {
          format = " {:%H:%M}";
          format-alt = " {:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = " {usage}%";
          tooltip = true;
        };

        memory = {
          format = " {}%";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "  muted";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        tray = {
          spacing = 10;
        };

        mpris = {
          format = "{player_icon} {title}";
          format-paused = "{status_icon} {title}";
          player-icons = {
            default = "";
          };
          status-icons = {
            paused = "";
          };
        };
      };

      # Catppuccin Mocha theme
      style = ''
        * {
            min-height: 0;
            min-width: 0;
            font-family: Lexend, "JetBrainsMono NFP";
            font-size: 12px;
            font-weight: 500;
        }

        window#waybar {
            transition-property: background-color;
            transition-duration: 0.5s;
            background-color: rgba(24, 24, 37, 0.6);
        }

        #workspaces button {
            padding: 0.2rem 0.4rem;
            margin: 0.2rem 0.15rem;
            border-radius: 4px;
            background-color: #1e1e2e;
            color: #cdd6f4;
        }

        #workspaces button:hover {
            color: #1e1e2e;
            background-color: #cdd6f4;
        }

        #workspaces button.active {
            background-color: #1e1e2e;
            color: #89b4fa;
        }

        #workspaces button.urgent {
            background-color: #1e1e2e;
            color: #f38ba8;
        }

        #clock,
        #pulseaudio,
        #custom-logo,
        #custom-power,
        #cpu,
        #tray,
        #memory,
        #window,
        #mpris {
            padding: 0.2rem 0.4rem;
            margin: 0.2rem 0.15rem;
            border-radius: 4px;
            background-color: #1e1e2e;
        }

        #mpris.playing {
            color: #a6e3a1;
        }

        #mpris.paused {
            color: #9399b2;
        }

        #custom-sep {
            padding: 0px;
            color: #585b70;
        }

        window#waybar.empty #window {
            background-color: transparent;
        }

        #cpu {
            color: #94e2d5;
        }

        #memory {
            color: #cba6f7;
        }

        #clock {
            color: #74c7ec;
        }

        #clock.simpleclock {
            color: #89b4fa;
        }

        #window {
            color: #cdd6f4;
        }

        #pulseaudio {
            color: #b4befe;
        }

        #pulseaudio.muted {
            color: #a6adc8;
        }

        #custom-logo {
            color: #89b4fa;
        }

        #custom-power {
            color: #f38ba8;
        }

        tooltip {
            background-color: #181825;
            border: 2px solid #89b4fa;
        }
      '';
    };
  };
}

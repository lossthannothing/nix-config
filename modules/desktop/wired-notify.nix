# modules/desktop/wired-notify.nix
#
# wired-notify - Rust notification daemon
# Catppuccin Mocha color scheme
{
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    home.packages = [pkgs.wired-notify];

    # wired-notify config
    xdg.configFile."wired/wired.ron".text = ''
      (
        max_notifications: 10,
        timeout: 5000,
        poll_interval: 16,
        idle_threshold: 3000,
        unpause_on_input: true,
        shortcuts: (
          notification_interact: 1,
          notification_close: 2,
          notification_closeall: 3,
        ),

        layout_blocks: [
          (
            name: "root",
            parent: "",
            hook: (parent_anchor: TR, self_anchor: TR),
            offset: (x: -10.0, y: 40.0),
            params: NotificationBlock((
              monitor: 0,
              border_width: 2.0,
              border_rounding: 10.0,
              background_color: (hex: "#1e1e2e"),
              border_color: (hex: "#89b4fa"),
              gap: (x: 0.0, y: 8.0),
              notification_hook: (parent_anchor: BL, self_anchor: TL),
            )),
          ),

          (
            name: "summary",
            parent: "root",
            hook: (parent_anchor: TL, self_anchor: TL),
            offset: (x: 10.0, y: 10.0),
            params: TextBlock((
              text: "%s",
              font: "JetBrainsMono Nerd Font 11",
              color: (hex: "#cdd6f4"),
              ellipsize: End,
              padding: (left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
              dimensions: (width: (min: 200, max: 300), height: (min: 0, max: 0)),
            )),
          ),

          (
            name: "body",
            parent: "summary",
            hook: (parent_anchor: BL, self_anchor: TL),
            offset: (x: 0.0, y: 4.0),
            params: TextBlock((
              text: "%b",
              font: "JetBrainsMono Nerd Font 10",
              color: (hex: "#a6adc8"),
              ellipsize: End,
              padding: (left: 0.0, right: 0.0, top: 0.0, bottom: 10.0),
              dimensions: (width: (min: 200, max: 300), height: (min: 0, max: 100)),
            )),
          ),
        ],
      )
    '';
  };
}

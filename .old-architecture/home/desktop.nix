# home/desktop.nix
#
# Desktop environment configuration for NixOS VM
# NixOS 虚拟机的桌面环境配置
# Adapted from https://github.com/imlyzh/nixos

{ config, pkgs, dotfiles, ... }:

let
  # Terminal and launcher configuration
  my-terminal = "kitty";
  my-launcher = "fuzzel";

  # Wallpaper configuration
  wallpaper-path = "${config.home.homeDirectory}/.config/assets/wallpaper.png";
  wallpaper-cmd = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper-path}";
in {
  # Desktop packages
  home.packages = with pkgs; [
    # Fonts
    noto-fonts-cjk-sans
    font-awesome

    # Window managers and Wayland tools
    swayfx
    niri
    xwayland-satellite
    
    # Terminals
    kitty
    ghostty
    
    # Launchers and UI
    ulauncher
    bibata-cursors
    fuzzel
    waybar
    mako
    
    # System tools
    swaylock
    swayidle
    polkit
    swaybg
    
    # Screenshot and clipboard
    grim
    slurp
    wl-clipboard
    
    # Audio control
    pavucontrol
    
    # Input method
    ibus
    
    # Applications
    firefox
    file-roller
  ];

  # Terminal configuration
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };
  };

  # Browser
  programs.firefox.enable = true;

  # Ghostty terminal
  programs.ghostty = {
    enable = true;
    settings = {};
  };

  # Hyprland window manager
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      decoration = {
        rounding = 10;
        blur.enabled = true;
        inactive_opacity = 0.9;
        active_opacity = 0.9;
      };
      "exec-once" = [
        "waybar"
        "ghostty"
      ];
      "windowrulev2" = [
        "float, class:^(ulauncher)$"
        "center, class:^(ulauncher)$"
        "noborder, class:^(ulauncher)$"
        "noshadow, class:^(ulauncher)$"
        "rounding 0, class:^(ulauncher)$"
        "noblur, class:^(ulauncher)$"
        "opaque, class:^(ulauncher)$"
      ];
      bind = [
        "$mod, F, exec, firefox"
        "$mod, RETURN, exec, ghostty"
        "$mod, Q, killactive,"
        "$mod, D, exec, ulauncher"
      ] ++ (
        # Workspace bindings
        builtins.concatLists (builtins.genList (i:
          let ws = i + 1;
          in [
            "$mod, code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        ) 9)
      );
      binde = [
        "$mod, LEFT, resizeactive, -10 0"
        "$mod, RIGHT, resizeactive, 10 0"
        "$mod, UP, resizeactive, 0 -10"
        "$mod, DOWN, resizeactive, 0 10"
      ];
    };
  };

  # Cursor theme
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
  };

  # Environment variables
  home.sessionVariables = {
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "24";
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
  };

  # Configuration files
  home.file = {
    "./.config/waybar".source = "${dotfiles}/config/.config/waybar";
    "./.config/assets".source = "${dotfiles}/config/.config/assets";
    "./.config/niri/config.kdl".source = "${dotfiles}/config/.config/niri/config.kdl";
  };

  # Background service
  systemd.user.services.swaybg = {
    Unit = {
      Description = "Sway Background";
      PartOf = "graphical-session.target";
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper-path}";
      Restart = "on-failure";
      RestartSec = "1";
      TimeoutStopSec = "5";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
# home/apps/windsurf/wsl-compat.nix
# Application-level Home Manager module: Windsurf WSL launcher (optional)

{ config, lib, ... }:

let
  cfg = config.windsurf.wslLauncher;
  launcherPath = "${config.home.homeDirectory}/.config/windsurf/wsl/windsurf-launcher.sh";
  script = ''
    #!/usr/bin/env bash
    set -euo pipefail
    TARGET_PATH="${1:-.}"
    CURRENT_PATH=$(readlink -f "$TARGET_PATH")
    DISTRO_NAME="${WSL_DISTRO_NAME:-${cfg.distroName}}"
    exec windsurf --folder-uri "vscode-remote://wsl+${DISTRO_NAME}${CURRENT_PATH}"
  '';

in {
  options.windsurf.wslLauncher = {
    enable = lib.mkEnableOption "Enable Windsurf WSL launcher and zsh alias";
    alias = lib.mkOption {
      type = lib.types.str;
      default = "wf";
      description = "Alias to launch Windsurf bound to current WSL directory";
    };
    distroName = lib.mkOption {
      type = lib.types.str;
      default = "NixOS";
      description = "Fallback WSL distro name when $WSL_DISTRO_NAME is unset";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/windsurf/wsl/windsurf-launcher.sh" = {
      text = script;
      executable = true;
    };
    programs.zsh.shellAliases = {
      ${cfg.alias} = ''"${launcherPath} ."'';
    };
  };
}

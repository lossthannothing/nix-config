# home/apps/windsurf/wsl-compat.nix
# Application-level Home Manager module: Windsurf WSL launcher (optional)

{ config, lib, ... }:

let
  cfg = config.windsurf.wslLauncher;
  launcherPath = "${config.home.homeDirectory}/.config/windsurf/wsl/windsurf-launcher.sh";
  script = ''
    #!/usr/bin/env bash
    set -euo pipefail
  ''
  + lib.optionalString cfg.bridgeWindowsEnv ''
    # (optional) Prepare Windows env variables for GUI interop (no global export)
    # Use wslvar when available; if empty, fall back to cmd.exe echo.
    get_winvar() {
      local name="''${1}"
      local val=""
      if command -v wslvar >/dev/null 2>&1; then
        val="$(wslvar "''${name}" 2>/dev/null || true)"
      fi
      if [ -z "''${val}" ]; then
        # Fallback via Windows cmd; strip CR
        val="$(cmd.exe /c "echo %''${name}%" | tr -d '\r' 2>/dev/null || true)"
      fi
      printf '%s' "''${val}"
    }

    WIN_USERPROFILE_WIN="$(get_winvar USERPROFILE)"
    WIN_APPDATA_WIN="$(get_winvar APPDATA)"
    WIN_LOCALAPPDATA_WIN="$(get_winvar LOCALAPPDATA)"
  ''
  + ''
    TARGET_PATH="''${1:-.}"
    CURRENT_PATH=$(readlink -f "$TARGET_PATH")
    DISTRO_NAME="''${WSL_DISTRO_NAME:-${cfg.distroName}}"

    # Prefer 'windsurf' from PATH; if it's the Linux CLI inside WSL, open the path directly.
    # Fallback to Windows-installed Windsurf via LOCALAPPDATA when present.
    if command -v windsurf >/dev/null 2>&1; then
      exec windsurf "''${CURRENT_PATH}"
    else
      if command -v wslpath >/dev/null 2>&1; then
        # Resolve Windows Windsurf.exe from LOCALAPPDATA when available
        WIN_LOCALAPPDATA_WIN="''${WIN_LOCALAPPDATA_WIN:-}"
        CANDIDATE="$(wslpath -u "''${WIN_LOCALAPPDATA_WIN}\\Programs\\Windsurf\\Windsurf.exe" 2>/dev/null || true)"
        if [ -x "''${CANDIDATE}" ]; then
          # Only set Windows env for the Windows process (no global export)
          USERPROFILE="''${WIN_USERPROFILE_WIN:-}" \
          APPDATA="''${WIN_APPDATA_WIN:-}" \
          LOCALAPPDATA="''${WIN_LOCALAPPDATA_WIN:-}" \
          TEMP="''${WIN_LOCALAPPDATA_WIN:-}\\Temp" \
          TMP="''${WIN_LOCALAPPDATA_WIN:-}\\Temp" \
          exec "''${CANDIDATE}" --folder-uri "vscode-remote://wsl+''${DISTRO_NAME}''${CURRENT_PATH}"
        fi
      fi
      echo "windsurf executable not found; please ensure it is installed and on PATH" >&2
      exit 127
    fi
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
    bridgeWindowsEnv = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to export Windows USERPROFILE/APPDATA/LOCALAPPDATA/TEMP for GUI interop (some Electron apps need this).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/windsurf/wsl/windsurf-launcher.sh" = {
      text = script;
      executable = true;
    };
    programs.zsh.shellAliases = {
      "${cfg.alias}" = ''${launcherPath} .'';
    };
  };
}

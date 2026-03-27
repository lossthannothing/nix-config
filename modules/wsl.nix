# modules/wsl.nix
#
# loss.wsl - WSL platform aspect
# NixOS: WSL core config (module import, base settings, interop)
# HomeManager: User environment (aliases, scripts, paths)
{inputs, ...}: let
  # Windows user configuration
  winUser = "Lossilklauralin";
in {
  loss.wsl = {
    nixos = _: {
      imports = [inputs.nixos-wsl.nixosModules.default];

      wsl = {
        enable = true;
        wslConf.automount.root = "/mnt";
        wslConf.interop.appendWindowsPath = false;
      };

      programs.nix-ld.enable = true;
    };

    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = with pkgs; [
        wslu
        (pkgs.writeShellScriptBin "windsurf-launcher" ''
          #!/bin/sh
          DISTRO="''${WSL_DISTRO_NAME:-NixOS}"
          CURRENT_PATH=$(readlink -f "$1")
          WIN_USER="''${WIN_USER:-${winUser}}"

          WINDSURF_EXE="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Windsurf/bin/windsurf"
          if [ ! -f "$WINDSURF_EXE" ]; then
            WINDSURF_EXE="/mnt/c/Program Files/Windsurf/bin/windsurf"
          fi

          if [ ! -f "$WINDSURF_EXE" ]; then
            echo "Error: Windsurf executable not found"
            exit 1
          fi

          "$WINDSURF_EXE" --folder-uri "vscode-remote://wsl+''${DISTRO}''${CURRENT_PATH}"
        '')
      ];

      home.sessionVariables = {
        WIN_USER = winUser;
        BROWSER = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe";
        DISPLAY = ":0";
      };

      home.shellAliases = {
        explorer = "/mnt/c/Windows/explorer.exe";
        notepad = "/mnt/c/Windows/System32/notepad.exe";
        cdwin = "cd /mnt/c/Users/$WIN_USER";
        cddownloads = "cd /mnt/c/Users/$WIN_USER/Downloads";
        cddesktop = "cd /mnt/c/Users/$WIN_USER/Desktop";
        wf = "windsurf-launcher .";
      };

      programs.zsh.initContent = lib.mkAfter ''
        export PATH="$PATH:/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/bin"
      '';
    };
  };
}

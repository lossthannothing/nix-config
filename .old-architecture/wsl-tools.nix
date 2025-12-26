# hosts/wsl/wsl-tools.nix
#
# WSL-specific tools and integrations
# WSL 特定工具和集成
{
  pkgs,
  lib,
  ...
}:
{
  # WSL-specific system packages
  environment.systemPackages = with pkgs; [
    # Windows integration tools
    wslu

    # Windsurf WSL launcher
    (pkgs.writeShellScriptBin "windsurf-launcher" ''
      #!/bin/sh
      CURRENT_PATH=$(readlink -f "$1")
      # WSL 发行版名称为 NixOS

      # 直接调用windsurf.exe并传递正确的参数
      WIN_USER="''${WIN_USER:-Lossilklauralin}"
      WINDSURF_EXE="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Windsurf/bin/windsurf"

      if [ ! -f "$WINDSURF_EXE" ]; then
        WINDSURF_EXE="/mnt/c/Program Files/Windsurf/bin/windsurf"
      fi

      if [ ! -f "$WINDSURF_EXE" ]; then
        echo "Error: Windsurf executable not found"
        exit 1
      fi

      "$WINDSURF_EXE" --folder-uri "vscode-remote://wsl+NixOS$CURRENT_PATH"
    '')

    # MCPS environment setup
    (pkgs.writeShellScriptBin "mcps-env-setup" ''
      #!/bin/sh
      # MCPS 相关环境变量
      export MCPS_HOME="/mnt/d/Workspace/Crack_IDE/mcps"
      export CUNZHI_CLI="/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli"

      # 添加 MCPS 相关路径到 PATH
      export PATH="/mnt/d/Workspace:$PATH"
      export PATH="/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli:$PATH"

      # 验证环境变量
      echo "MCPS environment configured:"
      echo "MCPS_HOME: $MCPS_HOME"
      echo "CUNZHI_CLI: $CUNZHI_CLI"
    '')
  ];

  # WSL-specific environment variables
  environment.variables = {
    WIN_USER = "Lossilklauralin";
    BROWSER = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe";
    MCPS_HOME = "/mnt/d/Workspace/Crack_IDE/mcps";
    CUNZHI_CLI = "/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli";
  };

  # Append MCPS-related paths to PATH for interactive shells (WSL-scoped via module import)
  environment.interactiveShellInit = lib.mkAfter ''
    export PATH="$PATH:/mnt/d/Workspace:/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli"
    export PATH="$PATH:/mnt/c/Users/Lossilklauralin/AppData/Local/Programs/Microsoft VS Code/bin"
  '';

  # System-wide shell aliases for WSL
  environment.shellAliases = {
    # Windows commands
    explorer = "/mnt/c/Windows/explorer.exe";
    notepad = "/mnt/c/Windows/System32/notepad.exe";
    # Quick navigation
    cdwin = "cd /mnt/c/Users/$WIN_USER";
    cddownloads = "cd /mnt/c/Users/$WIN_USER/Downloads";
    cddesktop = "cd /mnt/c/Users/$WIN_USER/Desktop";

    # Tool shortcuts
    wf = "windsurf-launcher .";
    mcps-setup = "mcps-env-setup";
    mcps-check = "echo 'MCPS_HOME:' $MCPS_HOME && echo 'CUNZHI_CLI:' $CUNZHI_CLI";
  };
}

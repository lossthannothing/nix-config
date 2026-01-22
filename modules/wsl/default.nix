# modules/wsl/default.nix
#
# WSL 统一配置模块
# - nixos.wsl: NixOS 系统级配置 (Bootloader, Docker, Interop 等)
# - homeManager.wsl: 用户级环境配置 (Shell, Aliases, Scripts 等) - 跨发行版通用
{
  flake.modules = {
    # ============================================================
    # 注入到 nixos.wsl (仅 NixOS-WSL 使用)
    # ============================================================
    nixos.wsl = _: {
      # WSL 核心配置
      wsl = {
        enable = true;
        defaultUser = "loss";
        docker-desktop.enable = true;
        wslConf.automount.root = "/mnt";
        # 我们在 homeManager.wsl 中手动管理 PATH，避免 Windows 路径污染过重
        wslConf.interop.appendWindowsPath = false;
      };

      # 禁用系统引导 (WSL 自带引导)
      boot.loader.systemd-boot.enable = false;
      boot.loader.grub.enable = false;

      # 禁用冲突服务
      systemd.services.systemd-resolved.enable = false;
      systemd.services.systemd-networkd.enable = false;

      # NixOS 兼容性
      programs.nix-ld.enable = true;

      # 系统级环境变量
      environment.variables.MCPS_HOME = "/mnt/d/Workspace/Crack_IDE/mcps";

      # 平台定义
      nixpkgs.hostPlatform = "x86_64-linux";
    };

    # ============================================================
    # 注入到 homeManager.wsl (NixOS / Fedora / Ubuntu 通用)
    # ============================================================
    homeManager.wsl = {
      pkgs,
      lib,
      ...
    }: {
      # 1. 通用工具包
      home.packages = with pkgs; [
        wslu
        (pkgs.writeShellScriptBin "windsurf-launcher" ''
          #!/bin/sh
          DISTRO="''${WSL_DISTRO_NAME:-NixOS}"
          CURRENT_PATH=$(readlink -f "$1")
          WIN_USER="''${WIN_USER:-Lossilklauralin}"

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

      # 2. 环境变量
      home.sessionVariables = {
        WIN_USER = "Lossilklauralin";
        BROWSER = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe";
      };

      # 3. 常用别名
      home.shellAliases = {
        explorer = "/mnt/c/Windows/explorer.exe";
        notepad = "/mnt/c/Windows/System32/notepad.exe";
        clip = "/mnt/c/Windows/System32/clip.exe";
        cdwin = "cd /mnt/c/Users/$WIN_USER";
        cddownloads = "cd /mnt/c/Users/$WIN_USER/Downloads";
        cddesktop = "cd /mnt/c/Users/$WIN_USER/Desktop";
        wf = "windsurf-launcher .";
      };

      # 4. PATH 路径注入 (兼容 Zsh)
      programs.zsh.initContent = lib.mkAfter ''
        export PATH="$PATH:/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/bin"
        export PATH="$PATH:/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli"
      '';
    };
  };
}

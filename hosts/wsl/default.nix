# hosts/wsl/default.nix
#
# WSL 主机配置 - 自注册到 flake.modules.nixos

{ config, inputs, pkgs, lib, ... }:

{
  # 自注册到 flake.modules.nixos."hosts/nixos-wsl"
  flake.modules.nixos."hosts/nixos-wsl" =
    {
      imports =
        with config.flake.modules.nixos;
        [
          # 1. 平台基底 - NixOS-WSL 模块
          inputs.nixos-wsl.nixosModules.default

          # 2. NixOS 模块
          base # 基础配置（从 modules/base/default.nix）
          loss # 用户配置（从 modules/users/loss.nix）
        ]
        # 3. Home Manager 配置（直接内联）
        ++ [
          {
            home-manager.users.loss = {
              imports = with config.flake.modules.homeManager; [
                base # 基础 Home Manager 配置
                shell # 所有 shell 工具（自动合并所有 modules/shell/*.nix）
                dev # 所有开发工具（自动合并所有 modules/dev/*.nix）
              ];
            };
          }
        ]
        # 4. WSL 特定配置
        ++ [
          {
            # WSL 配置
            wsl = {
              enable = true;
              defaultUser = "loss";
              wrapBinSh = true;
              useWindowsDriver = true;
              startMenuLaunchers = true;
              docker-desktop.enable = true;

              wslConf.automount.root = "/mnt";
              wslConf.interop.appendWindowsPath = false;
            };

            # 禁用不需要的引导加载程序
            boot.loader.systemd-boot.enable = false;
            boot.loader.grub.enable = false;

            # 禁用不需要的 systemd 服务
            systemd.services.systemd-resolved.enable = false;
            systemd.services.systemd-networkd.enable = false;

            # VS Code Remote SSH 支持
            programs.nix-ld.enable = true;

            # WSL 特定的系统包
            environment.systemPackages = with pkgs; [
              wslu # WSL 工具

              # Windsurf WSL 启动器
              (pkgs.writeShellScriptBin "windsurf-launcher" ''
                #!/bin/sh
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

                "$WINDSURF_EXE" --folder-uri "vscode-remote://wsl+NixOS$CURRENT_PATH"
              '')

              # MCPS 环境设置
              (pkgs.writeShellScriptBin "mcps-env-setup" ''
                #!/bin/sh
                export MCPS_HOME="/mnt/d/Workspace/Crack_IDE/mcps"
                export CUNZHI_CLI="/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli"
                export PATH="/mnt/d/Workspace:$PATH"
                export PATH="/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli:$PATH"

                echo "MCPS environment configured:"
                echo "MCPS_HOME: $MCPS_HOME"
                echo "CUNZHI_CLI: $CUNZHI_CLI"
              '')
            ];

            # WSL 环境变量
            environment.variables = {
              WIN_USER = "Lossilklauralin";
              BROWSER = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe";
              MCPS_HOME = "/mnt/d/Workspace/Crack_IDE/mcps";
              CUNZHI_CLI = "/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli";
            };

            # 交互式 Shell 路径设置
            environment.interactiveShellInit = lib.mkAfter ''
              export PATH="$PATH:/mnt/d/Workspace:/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli"
              export PATH="$PATH:/mnt/c/Users/Lossilklauralin/AppData/Local/Programs/Microsoft VS Code/bin"
            '';

            # WSL 别名
            environment.shellAliases = {
              explorer = "/mnt/c/Windows/explorer.exe";
              notepad = "/mnt/c/Windows/System32/notepad.exe";
              cdwin = "cd /mnt/c/Users/$WIN_USER";
              cddownloads = "cd /mnt/c/Users/$WIN_USER/Downloads";
              cddesktop = "cd /mnt/c/Users/$WIN_USER/Desktop";
              wf = "windsurf-launcher .";
              mcps-setup = "mcps-env-setup";
              mcps-check = "echo 'MCPS_HOME:' $MCPS_HOME && echo 'CUNZHI_CLI:' $CUNZHI_CLI";
            };

            # 系统版本
            system.stateVersion = "24.05";
          }
        ];
    };
}

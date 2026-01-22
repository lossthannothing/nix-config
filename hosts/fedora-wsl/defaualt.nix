# hosts/fedora-wsl/default.nix
#
# Fedora 42 WSL 独立配置 - 自注册到 flake.modules.homeManager
{
  config,
  lib,
  pkgs,
  ...
}: {
  # 自注册到 flake.modules.homeManager."hosts/fedora-wsl"
  # 这里不走 flake.modules.nixos，因为 Fedora 是 Standalone 模式
  flake.modules.homeManager."hosts/fedora-wsl" = {
    pkgs,
    lib,
    ...
  }: {
    imports = with config.flake.modules.homeManager; [
      base   # 基础 Home Manager 配置 (含 stateVersion)
      shell  # 所有 shell 工具 (自动合并 modules/shell/*.nix)
      dev    # 所有开发工具 (自动合并 modules/dev/*.nix)
      loss   # 用户特定配置 (modules/users/loss/default.nix)
    ];

    home = {
      username = "loss";
      homeDirectory = "/home/loss";
      # 继承 base 模块中的 stateVersion，此处不再重复定义以防冲突
    };

    # 针对非 NixOS (Fedora) 的兼容性层，必须开启
    targets.genericLinux.enable = true;

    # --- 业务逻辑：移植原 WSL Host 中的脚本与配置 ---

    home.packages = with pkgs; [
      wslu # WSL 工具

      # Windsurf WSL 启动器 (针对 Fedora 环境调整路径)
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

        # 注意这里远程路径改为 Fedora
        "$WINDSURF_EXE" --folder-uri "vscode-remote://wsl+Fedora$CURRENT_PATH"
      '')
    ];

    # 环境变量
    home.sessionVariables = {
      WIN_USER = "Lossilklauralin";
      BROWSER = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe";
    };

    # 路径设置 (由于没有 environment.interactiveShellInit，直接注入 programs.zsh)
    programs.zsh.initContent = lib.mkAfter ''
      export PATH="$PATH:/mnt/d/Workspace:/mnt/d/Workspace/Crack_IDE/mcps/cunzhi-cli"
      export PATH="$PATH:/mnt/c/Users/Lossilklauralin/AppData/Local/Programs/Microsoft VS Code/bin"
    '';

    # 别名 (使用 home.shellAliases)
    home.shellAliases = {
      explorer = "/mnt/c/Windows/explorer.exe";
      notepad = "/mnt/c/Windows/System32/notepad.exe";
      clip = "/mnt/c/Windows/System32/clip.exe";
      cdwin = "cd /mnt/c/Users/Lossilklauralin";
      cddownloads = "cd /mnt/c/Users/Lossilklauralin/Downloads";
      cddesktop = "cd /mnt/c/Users/Lossilklauralin/Desktop";
      wf = "windsurf-launcher .";
    };
  };
}
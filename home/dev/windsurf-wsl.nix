# home/dev/windsurf-wsl.nix
{ config, pkgs, lib, ... }:

{
  # 为这个特定的兼容功能定义一个清晰的、可开关的选项
  options.programs.windsurf.wsl-compat.enable = lib.mkEnableOption "Windsurf WSL compatibility layer";

  # 只有当选项被启用时，下面的配置才会生效
  config = lib.mkIf config.programs.windsurf.wsl-compat.enable {

    # 注意：此模块应仅在WSL环境中启用
    # 已通过配置结构确保只在WSL平台使用

    home.packages = [
      (pkgs.writeShellScriptBin "windsurf-launcher" ''
        #!/bin/sh
        CURRENT_PATH=$(readlink -f "$1")
        # WSL 发行版名称为 NixOS
        windsurf --folder-uri "vscode-remote://wsl+NixOS$CURRENT_PATH"
      '')
    ];

    home.shellAliases = {
      wf = "windsurf-launcher .";
    };

  };
}
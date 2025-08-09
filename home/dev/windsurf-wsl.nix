# home/dev/windsurf-wsl.nix
{ config, pkgs, lib, ... }:

{
  # 为这个特定的兼容功能定义一个清晰的、可开关的选项
  options.programs.windsurf.wsl-compat.enable = lib.mkEnableOption "Windsurf WSL compatibility layer";

  # 只有当选项被启用时，下面的配置才会生效
  config = lib.mkIf config.programs.windsurf.wsl-compat.enable {

    # 检查当前系统是否为 WSL，增加一层保险
    # 如果您确定只会在 wsl 主机上手动启用它，这行可以省略，但加上更健壮
    assertions = [{
      assertion = config.isWSL;
      message = "The Windsurf WSL compatibility layer can only be enabled on a WSL system.";
    }];

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
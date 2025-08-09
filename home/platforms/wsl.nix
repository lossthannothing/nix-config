# home/platforms/wsl.nix
#
# WSL platform-specific Home Manager configuration
# WSL 平台特定的 Home Manager 配置

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # 启用 Windsurf WSL 兼容层
  programs.windsurf.wsl-compat.enable = true;

  # WSL-specific user environment settings
  home.sessionVariables = {
    # Windows integration
    BROWSER = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe";
    
    # WSL-specific paths
    # WSLENV = "USERPROFILE/p:APPDATA/p";
  };

  # WSL-specific aliases
  home.shellAliases = {
    # Windows commands
    explorer = "/mnt/c/Windows/explorer.exe";
    notepad = "/mnt/c/Windows/System32/notepad.exe";
    
    # Quick navigation to Windows directories
    cdwin = "cd /mnt/c/Users/$USER";
    cddownloads = "cd /mnt/c/Users/$USER/Downloads";
    cddesktop = "cd /mnt/c/Users/$USER/Desktop";
  };

  # WSL-specific packages
  home.packages = with pkgs; [
    # Windows integration tools
    wslu
  ];
}
# modules/profiles/wsl.nix
#
# loss.profiles.wsl - WSL user preferences
# HomeManager: aliases, environment, Windows integration
let
  winUser = "Lossilklauralin";
in {
  loss.profiles.wsl.homeManager = {pkgs, lib, ...}: {
    home.packages = with pkgs; [wslu];

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
    };

    programs.zsh.initContent = lib.mkAfter ''
      export PATH="$PATH:/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/bin"
    '';
  };
}

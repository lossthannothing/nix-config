{
  flake.modules.homeManager.shell = {lib, ...}: {
    programs.bat = {
      enable = true;
      config.theme = lib.mkDefault "TwoDark";
    };

    # 用 bat 替代 cat
    programs.zsh.shellAliases.cat = "bat";
  };
}

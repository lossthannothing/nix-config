{
  flake.modules.homeManager.shell = {
    programs.bat = {
      enable = true;
      config.theme = "TwoDark";
    };

    # 用 bat 替代 cat
    programs.zsh.shellAliases.cat = "bat";
  };
}

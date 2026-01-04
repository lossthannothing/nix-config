# eza - 现代化的 ls 替代品
{
  flake.modules.homeManager.shell = {
    programs.eza = {
      enable = true;
      enableZshIntegration = true;

      git = true;
      icons = "auto";

      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    # 设置自定义别名
    programs.zsh.shellAliases = {
      ls = "eza";
      ll = "eza -lh --git";
      la = "eza -lah --git";
    };
  };
}

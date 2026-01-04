# ripgrep - 快速文本搜索工具
{
  flake.modules.homeManager.dev = {
    programs.ripgrep = {
      enable = true;

      arguments = [
        # 默认搜索隐藏文件
        "--hidden"
        # 遵守 gitignore
        "--glob=!.git/*"
        # 智能大小写
        "--smart-case"
      ];
    };
  };
}

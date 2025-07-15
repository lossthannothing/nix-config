{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    sheldon
    which
    lsd
    lstr
    fd
    hyperfine
    just
    neofetch
  ];
  programs = {
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    zsh = {
      enable = true;

      # Home Manager 会将这部分内容添加到 ~/.zshenv 文件中
      envExtra = ''
        # 检查私有环境文件是否存在，如果存在，则加载它
        if [ -f "$HOME/.private_env.sh" ]; then
          . "$HOME/.private_env.sh"
        fi
      '';
    };
    fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git"; # 使用 fd 替代 find
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
      ];
    };
  };

  home.file = {
    # 主入口文件
    ".zshrc".source = "${dotfiles}/zsh/.zshrc";

    # 其他子文件被链接到 ~/.zsh/ 目录下
    ".zsh/aliases.zsh".source = "${dotfiles}/zsh/.zsh/aliases.zsh";
    ".zsh/functions.zsh".source = "${dotfiles}/zsh/.zsh/functions.zsh";

    # Sheldon 的配置文件
    ".config/sheldon/plugins.toml".source = "${dotfiles}/config/.config/sheldon/plugins.toml";
    # p10k主题
    ".p10k.zsh".source = "${dotfiles}/zsh/.p10k.zsh";
  };
}

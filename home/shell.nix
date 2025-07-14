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
  programs ={
    zoxide.enable=true;
    zsh.enable=true;
    fzf = {
      enable=true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git"; # 使用 fd 替代 find
      defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
    }
  }

  home.file = {
    # 主入口文件
    ".zshrc".source = "${dotfiles}/zsh/.zshrc";

    # 其他子文件被链接到 ~/.zsh/ 目录下
    ".zsh/aliases.zsh".source = "${dotfiles}/zsh/.zsh/aliases.zsh";
    ".zsh/functions.zsh".source = "${dotfiles}/zsh/.zsh/functions.zsh";

    # Sheldon 的配置文件
    ".config/sheldon/plugins.toml".source = "${dotfiles}/config/.config/sheldon/plugins.toml";
  };
}

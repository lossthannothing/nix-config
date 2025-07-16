{
  pkgs,
  lib,
  dotfiles,
  config,
  ...
}:

{
  # 错误日志中指出的问题就在这一部分
  home.packages = with pkgs; [
    # 插件管理和工具
    sheldon
    fnm

    # 核心工具
    which
    lsd
    lstr
    fd
    hyperfine
    just
    neofetch

    # 解压工具 (支持 extract 函数)
    unzip
    unrar
    p7zip
    xz
    cabextract

    (nerd-fonts.jetbrains-mono)
  ];

  programs = {
    bat.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
      ];
    };

    zsh = {
      enable = true;

      envExtra = ''
        # 私有环境变量将通过 Home Manager activation 设置
        # 使用标准化的 XDG 配置路径
        PRIVATE_ENV_CONFIG="${config.xdg.configHome}/private/env"
        if [ -r "$PRIVATE_ENV_CONFIG" ] && [ -f "$PRIVATE_ENV_CONFIG" ]; then
          set -a
          source "$PRIVATE_ENV_CONFIG"
          set +a
        fi

        # 添加本地 bin 目录到 PATH
        export PATH="$HOME/.local/bin:$PATH"
      '';

      shellAliases = {
        ls = "lsd";
        ll = "lsd -alhF";
        la = "lsd -A";
        cat = "bat";
        grep = "grep --color=auto";
        zi = "z -i";
        ".." = "cd ..";
        "..." = "cd ../..";
        extr = "extract";
        extrr = "extract_and_remove";

        # 现在可以使用最简化的命令了！
        hms = "nix run home-manager/master -- switch --flake .";

        # 明确指定架构的选项
        hms-x86 = "nix run home-manager/master -- switch --flake .#loss@x86_64-linux";
        hms-arm = "nix run home-manager/master -- switch --flake .#loss@aarch64-linux";

        hmg = "nix run home-manager/master -- generations";
        hmn = "nix run home-manager/master -- news";
        hmtoday = "nix run home-manager/master -- expire-generations '-1 days'";
        hmwk = "nix run home-manager/master -- expire-generations '-7 days'";
        hmu = "nix flake update";
      };

      initContent =
        let
          p10kInit = lib.mkOrder 500 ''
            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi
            [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
          '';

          toolsInit = lib.mkOrder 1000 ''
            if command -v sheldon &> /dev/null; then
              eval "$(sheldon source)"
            fi
            if command -v fnm &> /dev/null; then
              eval "$(fnm env)"
            fi
          '';

          functionsInit = lib.mkOrder 1000 ''
            # Source functions from the dotfiles submodule
                source "${dotfiles}/zsh/.zsh/functions.zsh"
          '';
        in
        lib.mkMerge [
          p10kInit
          toolsInit
          functionsInit
        ];
    };
  };

  home.file = {
    ".config/sheldon/plugins.toml".source = "${dotfiles}/config/.config/sheldon/plugins.toml";
    ".p10k.zsh".source = "${dotfiles}/zsh/.p10k.zsh";
  };
}

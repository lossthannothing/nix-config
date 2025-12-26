# modules/shell/zsh.nix
#
# ZSH 配置

{ pkgs, dotfiles, lib, ... }:

{
  flake.modules.homeManager.shell = { config, ... }: {
    programs.zsh = {
      enable = true;

      envExtra = ''
        # 私有环境变量配置
        PRIVATE_ENV_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/private/env"
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
            source "${dotfiles}/zsh/.zsh/functions.zsh"
          '';
        in
        lib.mkMerge [
          p10kInit
          toolsInit
          functionsInit
        ];
    };

    # ZSH 相关的 dotfiles
    home.file.".p10k.zsh".source = "${dotfiles}/zsh/.p10k.zsh";
  };
}

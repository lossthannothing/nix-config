# modules/shell/zsh.nix
#
# Zsh - primary shell configuration
# oh-my-zsh for git/fzf plugins, history, aliases, functions
{
  flake.modules.homeManager.shell = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [pkgs.zsh-completions];

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = ["git" "fzf"];
      };

      history = {
        ignoreDups = true;
        share = true;
        extended = true;
        size = 50000;
        save = 50000;
      };

      envExtra = ''
        # Private env config sourcing
        PRIVATE_ENV_CONFIG="''${XDG_CONFIG_HOME:-$HOME/.config}/private/env"
        if [ -r "$PRIVATE_ENV_CONFIG" ] && [ -f "$PRIVATE_ENV_CONFIG" ]; then
          set -a
          source "$PRIVATE_ENV_CONFIG"
          set +a
        fi
        export PATH="$HOME/.local/bin:$PATH"
      '';

      shellAliases = {
        ".." = "cd ..";
        "..." = "cd ../..";
        extr = "extract";
        extrr = "extract_and_remove";
        grep = "grep --color=auto";
        zi = "z -i";
      };

      initContent = let
        toolsInit = lib.mkOrder 1000 ''
          if command -v fnm &> /dev/null; then
            eval "$(fnm env)"
          fi
        '';
        functionsInit = lib.mkOrder 1000 ''
          # Simple utility functions (inlined from dotfiles)
          up() {
            local count=''${1:-1}
            local dir=""
            for ((i=0; i<count; i++)); do
              dir="../$dir"
            done
            cd "$dir"
          }

          mkcd() {
            mkdir -p "$@" && cd "$_";
          }

          # Complex functions (inlined from dotfiles)

          # 统一解压函数
          function extract {
            if [ -z "$1" ]; then
              echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
            else
              if [ -f $1 ]; then
                case $1 in
                  *.tar.bz2)   tar xvjf $1    ;;
                  *.tar.gz)    tar xvzf $1    ;;
                  *.tar.xz)    tar xvJf $1    ;;
                  *.lzma)      unlzma $1      ;;
                  *.bz2)       bunzip2 $1     ;;
                  *.gz)        gunzip $1      ;;
                  *.tar)       tar xvf $1     ;;
                  *.tbz2)      tar xvjf $1    ;;
                  *.tgz)       tar xvzf $1    ;;
                  *.zip)       unzip $1       ;;
                  *.Z)         uncompress $1  ;;
                  *.7z)        7z x $1        ;;
                  *.xz)        unxz $1        ;;
                  *.exe)       cabextract $1  ;;
                  *)           echo "extract: '$1' - unknown archive method" ;;
                esac
              else
                echo "$1 - file does not exist"
              fi
            fi
          }

          # 解压并删除源文件
          function extract_and_remove {
            extract $1
            rm -f $1
          }
        '';
      in
        lib.mkMerge [toolsInit functionsInit];
    };
  };
}

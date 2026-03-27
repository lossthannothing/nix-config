# modules/shell.nix
#
# loss.shell - Shell tools and configuration
# Merged from: shell/zsh.nix, shell/starship.nix, shell/bat.nix, shell/eza.nix,
#   shell/fzf.nix, shell/fd.nix, shell/zoxide.nix, shell/yazi.nix,
#   shell/nix-your-shell.nix, shell/lstr.nix, shell/archive.nix
{
  loss.shell.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    # Archive tools
    home.packages = with pkgs; [
      unzip
      p7zip
      cabextract
      zsh-completions
      lstr
    ];

    # Zsh
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
        cat = "bat";
        ls = "eza";
        ll = "eza -lh --git";
        la = "eza -lah --git";
      };

      initContent = let
        toolsInit = lib.mkOrder 1000 ''
          if command -v fnm &> /dev/null; then
            eval "$(fnm env)"
          fi
        '';
        functionsInit = lib.mkOrder 1000 ''
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

          function extract_and_remove {
            extract $1
            rm -f $1
          }
        '';
      in
        lib.mkMerge [toolsInit functionsInit];
    };

    # Starship prompt
    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        continuation_prompt = "[.](bright-black) ";

        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[x](bold red)";
          vimcmd_symbol = "[<](bold green)";
          vimcmd_visual_symbol = "[<](bold yellow)";
          vimcmd_replace_symbol = "[<](bold purple)";
          vimcmd_replace_one_symbol = "[<](bold purple)";
        };

        git_commit.tag_symbol = " tag ";

        git_status = {
          ahead = ">";
          behind = "<";
          diverged = "<>";
          renamed = "r";
          deleted = "x";
        };

        git_branch = {
          symbol = "git ";
          truncation_symbol = "...";
        };

        os = {
          format = "[$name]($style) ";
          style = "bold yellow";
          disabled = false;
        };

        os.symbols = {
          NixOS = "nix ";
          Linux = "lnx ";
          Windows = "win ";
          Fedora = "fed ";
          Ubuntu = "ubnt ";
        };

        nix_shell.symbol = "nix ";
        rust.symbol = "rs ";
        golang.symbol = "go ";
        python.symbol = "py ";
        nodejs.symbol = "nodejs ";
        java.symbol = "java ";
        lua.symbol = "lua ";
        c.symbol = "C ";
        package.symbol = "pkg ";
        docker_context.symbol = "docker ";
        directory.read_only = " ro";

        status = {
          symbol = "[x](bold red) ";
          not_executable_symbol = "noexec";
          not_found_symbol = "notfound";
          sigint_symbol = "sigint";
          signal_symbol = "sig";
        };
      };
    };

    # Bat
    programs.bat = {
      enable = true;
      config.theme = lib.mkDefault "TwoDark";
    };

    # Eza
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

    # Fzf
    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--border"
      ];
    };

    # Other tools
    programs.fd.enable = true;

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = ["--cmd cd"];
    };

    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = false;
          sort_by = "natural";
          sort_dir_first = true;
        };
      };
    };

    programs.nix-your-shell = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}

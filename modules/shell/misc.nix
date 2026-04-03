# modules/shell/misc.nix
#
# loss.shell._.misc — archive tools, extract functions, misc utilities
{
  loss.shell._.misc.homeManager = {pkgs, lib, ...}: {
    home.packages = with pkgs; [
      unzip
      p7zip
      cabextract
      lstr
    ];

    home.shellAliases = {
      extr = "extract";
      extrr = "extract_and_remove";
    };

    programs.zsh.initContent = lib.mkOrder 1000 ''
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
  };
}

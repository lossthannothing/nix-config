# modules/shell/zsh.nix
#
# Zsh - primary shell configuration
# oh-my-zsh for git/fzf plugins, history, aliases, functions
{
  flake.modules.homeManager.shell = {
    dotfiles,
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

          # Complex functions sourced from dotfiles (proxy, extract)
          source "${dotfiles}/zsh/.zsh/functions.zsh"
        '';
      in
        lib.mkMerge [toolsInit functionsInit];
    };
  };
}

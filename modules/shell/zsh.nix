{
  flake.modules = {
    homeManager.shell = {
      dotfiles,
      lib,
      ...
    }: {
      programs.zsh = {
        enable = true;

        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;

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
          # 快速导航
          ".." = "cd ..";
          "..." = "cd ../..";

          # 压缩文件处理（引用 functions.zsh 中的函数）
          extr = "extract";
          extrr = "extract_and_remove";
        };

        initContent = let
          toolsInit = lib.mkOrder 1000 ''
            if command -v fnm &> /dev/null; then
              eval "$(fnm env)"
            fi
          '';

          functionsInit = lib.mkOrder 1000 ''
            source "${dotfiles}/zsh/.zsh/functions.zsh"
          '';
        in
          lib.mkMerge [
            toolsInit
            functionsInit
          ];
      };
    };
  };
}

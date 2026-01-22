{
  # 统一接口规范：显式接收 _pkgs 参数
  # 即使本模块目前未直接引用 pkgs，通过下划线前缀可避免 deadnix 报错
  flake.modules.homeManager.shell = {
    dotfiles,
    lib,
    ...
  }: {
    programs.zsh = {
      enable = true;

      # 修复：旧选项 enableAutosuggestions 已重命名为 autosuggestion.enable
      autosuggestion.enable = true;
      # 修复：旧选项 enableSyntaxHighlighting 已重命名为 syntaxHighlighting.enable
      syntaxHighlighting.enable = true;

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

      # 修复：根据最新的 flake check 警告，initContent 已过时，应使用 initContent
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
}

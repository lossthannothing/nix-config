# modules/dev/dev-tools.nix
#
# 开发工具和语言环境

{ pkgs, dotfiles, ... }:

{
  flake.modules.homeManager.dev = { config, ... }: {
    home.packages = with pkgs; [
      # 编辑器
      neovim
      lunarvim

      # Python
      uv

      # JavaScript/TypeScript
      fnm
      deno

      # Rust
      rustup

      # 其他工具
      ansible
      nixfmt-rfc-style
      devenv
      nix-output-monitor
    ];

    programs = {
      go.enable = true;
      bun.enable = true;
    };

    # 开发相关的 dotfiles
    home.file = {
      "./.config/lvim/config.lua".source = "${dotfiles}/config/.config/lvim/config.lua";

      # Claude 命令配置
      ".claude/commands/spec.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/commands/spec.md";
      };
    };
  };
}

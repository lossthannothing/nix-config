# modules/dev/claude.nix
#
# Claude 命令、skills 及插件配置
{
  flake.modules.homeManager.dev = {
    dotfiles,
    config,
    ...
  }: {
    # 1. 全局默认提示词 (用于配置 Serena 优先等全局逻辑)
    home.file.".claude/CLAUDE.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/CLAUDE.md";
    };

    # 2. NixOS 运行时 Skill
    home.file.".claude/skills/nixos-cc-runtime.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/skills/nixos-cc-runtime.md";
    };

    # 4. Nix 模块构建器插件
    home.file.".claude/plugins/nix-module-builder" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude-plugin/nix-module-builder";
      recursive = true;
    };
  };
}

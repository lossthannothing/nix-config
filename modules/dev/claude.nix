{
  flake.modules.homeManager.dev = {
    dotfiles,
    config,
    ...
  }: {
    # 必须包裹在 home.file 下
    home.file = {
      ".claude/CLAUDE.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/CLAUDE.md";
        force = true;
      };

      ".claude/skills/nixos-cc-runtime/skill.md" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/skills/nixos-cc-runtime/skill.md";
        force = true;
      };

      ".claude/plugins/nix-module-builder" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude-plugin/nix-module-builder";
        # 移除 recursive = true; 以整个目录作为软链接，效率最高
        force = true;
      };
    };
  };
}
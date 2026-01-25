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

      ".claude/skills/claude-skills" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/skills/claude-skills";
        force = true;
      };

      ".claude/skills/building-plugins" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/skills/building-plugins";
        force = true;
      };

      ".claude/skills/consiliency-spawn-terminal" = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/skills/consiliency-spawn-terminal";
        force = true;
      };
    };
  };
}

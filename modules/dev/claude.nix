{
  flake.modules.homeManager.dev = {
    dotfiles,
    config,
    ...
  }: {
    # 统一开启备份，防止手动修改的文件被无意覆盖
    home-manager.backupFileExtension = "bak";

    # 1. 独立文件：使用 force 确保覆盖
    home.file.".claude/CLAUDE.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/CLAUDE.md";
      force = true;
    };

    home.file.".claude/skills/nixos-cc-runtime.md" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude/skills/nixos-cc-runtime.md";
      force = true;
    };

    # 4. 插件文件夹：移除 recursive，使用 force
    # 这样 Home Manager 会把整个目录作为一个 Symlink 处理，效率最高且不涉及 mkdir
    home.file.".claude/plugins/nix-module-builder" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/claude/.claude-plugin/nix-module-builder";
      # 不要使用 recursive = true; 
      force = true; 
    };
  };
}
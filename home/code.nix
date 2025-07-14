# home/code.nix (修正后)
{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    neovim
    lunarvim
    uv
    fnm
    ansible
    git-lfs
  ];

  programs = {
    # Git 配置
    git = {
      enable = true;
      userName = "Lossilklauralin";
      userEmail = "lossilklauralin@gmail.com";

      # --- 直接被模块支持的顶层选项 ---
      init.defaultBranch = "main";
      lfs.enable = true;
      pull.rebase = true;
      rerere.enabled = true;
      help.autocorrect = "prompt";

      # --- 所有其他选项都必须放在 extraConfig 中 ---
      extraConfig = {
        core = {
          autocrlf = false;
          eol = "lf";
          excludesfile = "~/.global.gitignore";
        };
        column = {
          ui = "auto";
        };
        branch = {
          sort = "-committerdate";
        };
        tag = {
          sort = "version:refname";
        };
        diff = {
          renames = true; # <--- 已移入
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
        };
        push = {
          followTags = true; # <--- 已移入
          default = "simple";
          autoSetupRemote = true;
        };
        fetch = {
          prune = true; # <--- 已移入
          pruneTags = true;
        };
        rebase = {
          autoSquash = true; # <--- 已移入
          autoStash = true;
          updateRefs = true;
        };
        rerere = {
          autoupdate = true;
        };
        merge = {
          conflictstyle = "zdiff3";
        };
      };
    }; # <--- programs.git 结束

    # --- 其他程序模块 ---
    gh.enable = true;
    go.enable = true;
    bun.enable = true;
    lazygit.enable = true;
    rustup.enable = true;
  };

  home.file = {
    "./.config/lvim/config.lua".source = "${dotfiles}/config/.config/lvim/config.lua";
    ".global.gitignore".source = "${dotfiles}/git/.global.gitignore";
  };
}

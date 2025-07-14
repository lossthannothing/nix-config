{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    neovim
    lunarvim
    uv
    ansible
    git-lfs
  ];

  programs = {
    # Git 配置
    git = {
      enable = true;
      
      userName = "Lossilklauralin";
      userEmail = "lossilklauralin@gmail.com";

      init.defaultBranch = "main";
      
      lfs.enable = true;

      pull.rebase = true;
      fetch.prune = true;
      push.followTags = true;
      rebase.autoSquash = true;
      rerere.enabled = true;
      help.autocorrect = "prompt";
      diff.renames = true;

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
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
        };
        push = {
          default = "simple";
          autoSetupRemote = true;
        };
        fetch = {
          pruneTags = true;
        };
        rebase = {
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
    }; # <--- Git 配置结束

    # Language tools 和其他 programs
    gh.enable = true;
    go.enable = true;
    bun.enable = true;
    lazygit.enable = true;
    rustup.enable = true;
    fnm.enable = true; 
  }; 

  home.file = {
    "./.config/lvim/config.lua".source = "${dotfiles}/config/.config/lvim/config.lua";
    ".global.gitignore".source = "${dotfiles}/git/.global.gitignore";
  };
}

# modules/shell/starship.nix
#
# loss.shell._.starship — cross-shell prompt
{
  loss.shell._.starship.homeManager = {...}: {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        continuation_prompt = "[.](bright-black) ";

        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[x](bold red)";
          vimcmd_symbol = "[<](bold green)";
          vimcmd_visual_symbol = "[<](bold yellow)";
          vimcmd_replace_symbol = "[<](bold purple)";
          vimcmd_replace_one_symbol = "[<](bold purple)";
        };

        git_commit.tag_symbol = " tag ";

        git_status = {
          ahead = ">";
          behind = "<";
          diverged = "<>";
          renamed = "r";
          deleted = "x";
        };

        git_branch = {
          symbol = "git ";
          truncation_symbol = "...";
        };

        os = {
          format = "[$name]($style) ";
          style = "bold yellow";
          disabled = false;
        };

        os.symbols = {
          NixOS = "nix ";
          Linux = "lnx ";
          Windows = "win ";
          Fedora = "fed ";
          Ubuntu = "ubnt ";
        };

        nix_shell.symbol = "nix ";
        rust.symbol = "rs ";
        golang.symbol = "go ";
        python.symbol = "py ";
        nodejs.symbol = "nodejs ";
        java.symbol = "java ";
        lua.symbol = "lua ";
        c.symbol = "C ";
        package.symbol = "pkg ";
        docker_context.symbol = "docker ";
        directory.read_only = " ro";

        status = {
          symbol = "[x](bold red) ";
          not_executable_symbol = "noexec";
          not_found_symbol = "notfound";
          sigint_symbol = "sigint";
          signal_symbol = "sig";
        };
      };
    };
  };
}

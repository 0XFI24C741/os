{ ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";

      directory = {
        read_only = " 󰌾";
      };

      git_branch = {
        symbol = " ";
      };

      git_status = {
        # \${...} escapes Nix antiquotation; Starship receives literal ${...}
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?";
        modified = "!";
        staged = "+";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}

let
  ezaAliases = import ../shell-aliases.nix;
in
{
  programs.nushell = {
    enable = true;

    shellAliases = ezaAliases // {
      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";

      # Flake shortcuts
      nfu = "nix flake update";
      nfc = "nix flake check";

      # Editor
      e = "zeditor";
      org = "emacs ~/org";

      zj = "zellij";
    };

    extraConfig = ''
      $env.config.show_banner = false

      use ~/.config/nushell/commands.nu *
      source ~/.config/nushell/prompt.nu
    '';
  };

  home.file.".config/nushell/commands.nu".source = ./commands.nu;
  home.file.".config/nushell/prompt.nu".source = ./prompt.nu;
}

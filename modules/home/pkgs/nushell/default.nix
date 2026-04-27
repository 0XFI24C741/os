{ ... }:
{
  programs.nushell = {
    enable = true;

    shellAliases = {
      # ls replacements (eza)
      ls = "eza";
      ll = "eza -l --git";
      la = "eza -la --git";
      lt = "eza --tree --level=2";

      # Git shortcuts
      gs = "git status";
      gd = "git diff";
      gl = "git log --oneline --graph --decorate -20";

      # Flake shortcuts
      nfu = "nix flake update";
      nfc = "nix flake check";

      # Editor
      e = "zeditor";

      zj = "zellij";
    };

    extraConfig = ''
      $env.config.show_banner = false

      def flake-ref [] { $".#(sys host | get hostname)" }

      def --wrapped rebuild [...rest] {
        sudo nixos-rebuild switch --flake (flake-ref) ...$rest
      }

      def --wrapped rebuild-build [...rest] {
        nixos-rebuild build --flake (flake-ref) ...$rest
      }

      def --wrapped nd [...rest] {
        nix develop ...$rest -c nu
      }

      def --wrapped nsh [...rest] {
        nix-shell ...$rest --command nu
      }

      source ~/.config/nushell/prompt.nu
    '';
  };

  home.file.".config/nushell/prompt.nu".source = ./prompt.nu;
}

{ ... }:
{
  # Override DMS's auto-generated niri outputs file to pin DP-2 at scale 1.25.
  # DMS normally writes this file itself from its display config state, but
  # home-manager replaces it with a nix-store symlink so this wins.
  # Host-specific: the output name and mode only apply to maple's LG 4K panel.
  home-manager.users.fractal.xdg.configFile."niri/dms/outputs.kdl".text = ''
    // Managed by NixOS flake - do not edit manually

    output "DP-2" {
        mode "3840x2160@59.997"
        scale 1.25
        position x=0 y=0
    }
  '';
}

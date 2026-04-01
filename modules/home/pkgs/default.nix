{ pkgs, ... }:
{
  imports = [
    ./bash
  ];

  home.packages = with pkgs; [
    emacs-pgtk
    zed-editor
    discord
    claude-code
    (dbvisualizer.overrideAttrs (old: {
      installPhase = builtins.replaceStrings [ "${openjdk17}" ] [ "${openjdk21}" ] old.installPhase;
    }))

    gh
    sublime-merge
    telegram-desktop

    openvpn
    fastfetch

    postman
    obsidian
    synology-drive-client

    ripgrep
    fd
    jq
    eza
    curl
    wget
    tree
  ];
}

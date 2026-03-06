{ pkgs, ... }:
{
  imports = [
    ./bash
  ];

  home.packages = with pkgs; [
    zed-editor
    claude-code
    github-copilot-cli

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

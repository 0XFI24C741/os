{ pkgs, ... }:
{
  # Steam + Proton
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Performance tools
  programs.gamemode.enable = true;
  programs.corectrl.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
  ];

  # Kernel tweaks
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };
  boot.kernelParams = [ "split_lock_detect=off" ];

  # Controller support
  hardware.xpadneo.enable = true;
  hardware.steam-hardware.enable = true;
}

{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/gaming
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "maple";

  # Intel I225-V (rev 01) fix: disable ASPM and EEE to prevent network drops
  boot.kernelParams = [ "pcie_port_pm=off" ];
  systemd.services.fix-i225v = {
    description = "Disable EEE on Intel I225-V to prevent connection drops";
    after = [ "network-pre.target" ];
    wants = [ "network-pre.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ethtool}/bin/ethtool --set-eee enp14s0 eee off";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  home-manager.users."fractal" = {
    imports = [ ../../modules/home ];

    home = {
      username = "fractal";
      homeDirectory = "/home/fractal";
      stateVersion = "25.11";
    };
  };

  home-manager.extraSpecialArgs = {
    inherit inputs;
    username = "fractal";
    realname = "Arto Levi";
  };
}

{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/gaming
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "maple";

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

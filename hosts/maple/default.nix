{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/gaming
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "maple";

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

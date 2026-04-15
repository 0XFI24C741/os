{ ... }:

{
  imports = [
    ./nixos
    ./user
    ./desktop
    ./packages
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-backup";

  nixpkgs = {
    overlays = [

    ];

    config = {
      allowUnfree = true;
    };
  };

  system.stateVersion = "25.11";
}

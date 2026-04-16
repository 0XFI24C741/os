{ ... }:
{
  imports = [
    ./boot.nix
    ./audio.nix
    ./bluetooth.nix
    ./graphics.nix
    ./locale.nix
    ./nix.nix
    ./network.nix
    ./nix-ld.nix
    ./virtualization.nix
  ];

  services.udisks2.enable = true;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="388d", ATTRS{idProduct}=="0001", GROUP="users", MODE="0660"
  '';
}

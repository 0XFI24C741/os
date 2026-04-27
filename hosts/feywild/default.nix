{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  networking.hostName = "feywild";

  # LUKS swap unlock (host-specific)
  boot.initrd.luks.devices."luks-dac4e371-be5c-4224-b2e1-e531f5affdc0".device =
    "/dev/disk/by-uuid/dac4e371-be5c-4224-b2e1-e531f5affdc0";
}

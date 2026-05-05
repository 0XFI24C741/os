{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ethtool
    file
    git
    gocryptfs
    htop
    jq
    killall
    lm_sensors
    man-pages
    mc
    nvme-cli
    p7zip
    pciutils
    smartmontools
    unixtools.xxd
    usbutils
  ];
}

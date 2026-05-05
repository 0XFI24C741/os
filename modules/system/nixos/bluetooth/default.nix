{ lib, pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  systemd.user.services.blueman-applet.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.blueman}/bin/blueman-applet"
  ];

  systemd.services.bluetooth-unblock = {
    description = "Unblock Bluetooth before BlueZ starts";
    wantedBy = [ "bluetooth.service" ];
    before = [ "bluetooth.service" ];
    after = [ "systemd-rfkill.service" ];
    wants = [ "systemd-rfkill.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
    };
  };
}

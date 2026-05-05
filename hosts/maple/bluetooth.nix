{ pkgs, ... }:

{
  services.udev.extraRules = ''
    # MediaTek MT7922/RZ616 Bluetooth USB function can reset during early boot.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", ATTR{idProduct}=="0616", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", ATTR{idProduct}=="0616", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
  '';

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

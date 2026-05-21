{ config, pkgs, ... }:

let
  sddmTheme =
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "astronaut";
      themeConfig = {
        Background = "Backgrounds/fractal-login.jpg";
        DimBackground = "0.22";
        DimBackgroundColor = "#07110A";
        CropBackground = "true";

        Font = "Ubuntu";
        FontSize = "12";
        RoundCorners = "14";
        HeaderText = config.networking.hostName;

        PartialBlur = "true";
        Blur = "1.0";
        BlurMax = "36";
        HaveFormBackground = "true";
        FormBackgroundColor = "#0B120C";
        FormPosition = "left";
        VirtualKeyboardPosition = "left";

        HeaderTextColor = "#BBD99B";
        DateTextColor = "#C7D9B8";
        TimeTextColor = "#EEF7E9";
        LoginFieldBackgroundColor = "#111A12";
        PasswordFieldBackgroundColor = "#111A12";
        LoginFieldTextColor = "#EEF7E9";
        PasswordFieldTextColor = "#EEF7E9";
        UserIconColor = "#DDECD6";
        PasswordIconColor = "#DDECD6";
        PlaceholderTextColor = "#A7B89A";
        WarningColor = "#F2B8B5";
        LoginButtonTextColor = "#0D150E";
        LoginButtonBackgroundColor = "#BBD99B";
        SystemButtonsIconsColor = "#DDECD6";
        SessionButtonTextColor = "#DDECD6";
        VirtualKeyboardButtonTextColor = "#DDECD6";
        DropdownTextColor = "#EEF7E9";
        DropdownSelectedBackgroundColor = "#283B22";
        DropdownBackgroundColor = "#0B120C";
        HighlightTextColor = "#0D150E";
        HighlightBackgroundColor = "#BBD99B";
        HighlightBorderColor = "#BBD99B";
        HoverUserIconColor = "#BBD99B";
        HoverPasswordIconColor = "#BBD99B";
        HoverSystemButtonsIconsColor = "#BBD99B";
        HoverSessionButtonTextColor = "#BBD99B";
        HoverVirtualKeyboardButtonTextColor = "#BBD99B";

        HideVirtualKeyboard = "true";
        ForceLastUser = "true";
        PasswordFocus = "true";
        TranslatePlaceholderUsername = "user";
        TranslatePlaceholderPassword = "password";
        TranslateLogin = "login";
      };
    }).overrideAttrs
      (old: {
        installPhase = old.installPhase + ''
          chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds
          cp ${../../../assets/wallpapers/26.jpg} \
            $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/fractal-login.jpg
        '';
      });

  fantasqueSansMonoNoLoopK = pkgs.fantasque-sans-mono.overrideAttrs (_old: {
    src = pkgs.fetchzip {
      url = "https://github.com/belluzj/fantasque-sans/releases/download/v1.8.0/FantasqueSansMono-NoLoopK.zip";
      stripRoot = false;
      hash = "sha256-RnnyhP2zdRGk4XUe4fSibMFBhZmMqoKziE6TzcCSiL0=";
    };
  });
in

{
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  environment.systemPackages = with pkgs; [
    bibata-cursors
    libsForQt5.qt5ct
    kdePackages.qt6ct
    sddmTheme
  ];

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.accounts-daemon.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = [
      "gnome"
      "gtk"
    ];
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  services.xserver = {
    enable = true;
    xkb.layout = "us,ru";
    xkb.options = "grp:win_space_toggle";

    autoRepeatDelay = 300;
    autoRepeatInterval = 25;
  };

  services.displayManager.sddm = {
    enable = true;
    theme = "${sddmTheme}/share/sddm/themes/sddm-astronaut-theme";
    extraPackages = [
      sddmTheme
    ]
    ++ (with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
      qtvirtualkeyboard
    ]);
    settings = {
      General.InputMethod = "qtvirtualkeyboard";
      Theme = {
        CursorTheme = "Bibata-Modern-Classic";
        CursorSize = 24;
      };
    };
    wayland.enable = true;
  };

  programs.niri.enable = true;
  services.libinput.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    fira-code
    fira-code-symbols
    ubuntu-classic
    nerd-fonts.ubuntu-mono
    lmodern
    fantasqueSansMonoNoLoopK
    departure-mono
  ];
}

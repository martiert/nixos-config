{
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "caps:none,compose:lwin";

    libinput.enable = true;
    displayManager = {
      sddm.enable = true;
      defaultSession = "sway";
    };

    windowManager.i3.enable = true;

    useGlamor = true;
    wacom.enable = true;
  };

  programs.sway.enable = true;
  hardware.opengl.driSupport32Bit = true;
}

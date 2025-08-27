{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "clk_ignore_unused"
      "pd_ignore_unused"
    ];
    kernelPatches = [
      {
        name = "snapdragon-config";
        patch = null;
        extraConfig = ''
          TYPEC y
          PHY_QCOM_QMP y
          QCOM_CLK_RPM y
          MFD_QCOM_RPM y
          REGULATOR_QCOM_RPM y
          PHY_QCOM_QMP_PCIE y
          CLK_X1E80100_CAMCC y
        '';
      }
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        extraConfig = ''
          set recordfail=1
        '';
        extraPerEntryConfig = ''
          insmod gzio
          insmod ext2
          insmod part_gpt
          devicetree /dtbs/${pkgs.linuxPackages_latest.kernel.version}/qcom/x1e78100-lenovo-thinkpad-t14s.dtb
        '';
        extraFiles = {
          "dtbs/${pkgs.linuxPackages_latest.kernel.version}/qcom/x1e78100-lenovo-thinkpad-t14s.dtb" = "${pkgs.linuxPackages_latest.kernel}/dtbs/qcom/x1e78100-lenovo-thinkpad-t14s.dtb";
        };
      };
    };
  };

  hardware = {
    deviceTree = {
      enable = true;
      name = "qcom/x1e78100-lenovo-thinkpad-t14s.dtb";
    };
    enableRedistributableFirmware = true;
    firmware = [
      pkgs.lenovo-t14s-firmware
    ];
  };

  networking = {
    wireless = {
      iwd = {
        settings = {
          General = {
            ControlPortOverNL80211 = false;
          };
        };
      };
    };
  };
}

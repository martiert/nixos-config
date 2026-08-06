{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "clk_ignore_unused"
      "pd_ignore_unused"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub.enable = false;
      systemd-boot = {
        enable = true;
        edk2-uefi-shell.enable = true;
      };
    };
    initrd = {
      kernelModules = [
        # Storage
        "nvme"

        # Platform communication
        "qrtr"
        "qcom_glink_smem"

        # PHY drivers
        "phy_qcom_qmp_pcie"
        "phy_qcom_qmp_usb"
        "phy_qcom_qmp_combo"

        # Type-C
        "typec"
        "typec_ucsi"
        "ucsi_glink"
        "gpio_sbu_mux"
        "pmic_glink_altmode"

        # USB host
        "xhci_hcd"

        # HID
        "usbhid"
        "hid_generic"

        # Display
        "gpucc_sc8280xp"
        "dispcc_sc8280xp"
        "phy_qcom_edp"
        "panel_edp"
        "msm"

        # Input devices
        "hid_multitouch"
        "i2c_hid_of"
        "i2c_qcom_geni"

        # Other platform stuff
        "leds_qcom_lpg"
        "pwm_bl"
        "phy_qcom_edp"
        "qcom_pon"
        "qcom_pbs"
        "qcom_edac"
        "qcom_spmi_pmic"
      ];
    };
  };

  hardware = {
    deviceTree = {
      enable = true;
      name = "qcom/x1e78100-lenovo-thinkpad-t14s.dtb";
    };
    enableRedistributableFirmware = true;
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

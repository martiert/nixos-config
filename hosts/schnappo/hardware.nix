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
    initrd.kernelModules = [
      # Storage
      "nvme"

      # Platform communication (SCMI mailbox chain)
      "qrtr"
      "qcom_glink_smem"
      "pmic_glink"
      "qcom_cpucp_mbox"

      # PHY drivers
      "phy_qcom_qmp_pcie"
      "phy_qcom_qmp_combo"
      "phy_qcom_eusb2_repeater"
      "phy_snps_eusb2"

      # Mux controllers
      "mux_gpio"

      # Type-C
      "typec"
      "typec_ucsi"
      "ucsi_glink"
      "gpio_sbu_mux"
      "pmic_glink_altmode"
      "ps883x"

      # USB host
      "dwc3"
      "xhci_hcd"

      # HID
      "usbhid"
      "hid_generic"

      # Input devices (keyboard for password fallback)
      "i2c_hid_of"
      "i2c_qcom_geni"
    ];
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

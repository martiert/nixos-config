{ pkgs, ... }:

{
  boot = {
    kernelPackages = pkgs.t14s-kernel;
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
      extraFirmwarePaths = [
          "qcom/x1e80100/LENOVO/21N1/adsp_dtbs.elf"
          "qcom/x1e80100/LENOVO/21N1/adspr.jsn"
          "qcom/x1e80100/LENOVO/21N1/adsps.jsn"
          "qcom/x1e80100/LENOVO/21N1/adspua.jsn"
          "qcom/x1e80100/LENOVO/21N1/battmgr.jsn"
          "qcom/x1e80100/LENOVO/21N1/cdsp_dtbs.elf"
          "qcom/x1e80100/LENOVO/21N1/cdspr.jsn"
          "qcom/x1e80100/LENOVO/21N1/qcadsp8380.mbn"
          "qcom/x1e80100/LENOVO/21N1/qccdsp8380.mbn"
          "qcom/x1e80100/LENOVO/21N1/qcdxkmsuc8380.mbn"
      ];
      kernelModules = [
        "nvme"
        "phy_qcom_qmp_pcie"
        "phy_qcom_qmp_usb"
        "hid_multitouch"
        "i2c_hid_of"
        "i2c_qcom_geni"
        "leds_qcom_lpg"
        "pwm_bl"
        "qrtr"
        "pmic_glink_altmode"
        "gpio_sbu_mux"
        "phy_qcom_qmp_combo"
        "gpucc_sc8280xp"
        "dispcc_sc8280xp"
        "phy_qcom_edp"
        "panel_edp"
        "msm"
        "qcom_glink_smem"
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

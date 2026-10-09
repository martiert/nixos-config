{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "git+file:///home/martin/src/Projects/nix/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    notify = {
      url = "github:martiert/khal_notifications";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blocklist = {
      url = "github:hagezi/dns-blocklists";
      flake = false;
    };
    module = {
      url = "github:martiert/nixos-module";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        blocklist.follows = "blocklist";
      };
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, module, flake-utils, agenix, home-manager, nixos-hardware, notify, ... }@inputs:
    let
      lib = nixpkgs.lib.extend(self: super: (import ./lib) { 
        inherit nixpkgs module nixos-hardware home-manager agenix notify;
        secretsDir = ./secrets;
        lib = super;
      });
    in {
      nixosConfigurations = lib.forAllNixHosts lib.makeNixosConfig //
        {
          installer = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              ({ modulesPath, config, pkgs, ... }:
                let
                  ideacentreDtbName = "purwa-lenovo-ideacentre-mini-01q8x10";
                  kernel = config.boot.kernelPackages.kernel;
                  ideacentreDtb = kernel.overrideAttrs (old: {
                    pname = "${old.pname}-${ideacentreDtbName}-dtb";
                    outputs = [ "out" ];
                    patches = old.patches or [ ];
                    postPatch = (old.postPatch or "") + ''
                      commonDts=arch/arm64/boot/dts/qcom/x1-lenovo-ideacentre-mini-01q8x10.dtsi
                      cp arch/arm64/boot/dts/qcom/hamoa-lenovo-ideacentre-mini-01q8x10.dts "$commonDts"

                      # Recreate Jens's common board include from the upstream Hamoa
                      # board file shipped by this kernel version.
                      sed -i \
                        -e '/^\/dts-v1\/;$/d' \
                        -e '/^#include "hamoa.dtsi"$/d' \
                        -e '/^[[:space:]]*model = /d' \
                        -e '/^[[:space:]]*compatible = "lenovo,ideacentre-mini-01q8x10"/d' \
                        -e '/^&iris {$/,/^};$/d' \
                        -e '/^&gpu_zap_shader {$/,/^};$/d' \
                        -e '/^&remoteproc_adsp {$/,/^};$/d' \
                        -e '/^&remoteproc_cdsp {$/,/^};$/d' \
                        "$commonDts"
                      sed -i '/^$/N;/^\n$/D' "$commonDts"

                      # Jens's patches 5 and 6 (the kernel source predates the
                      # series, so apply them after the common-file split).
                      patch -p1 < ${./jens-ideacentre-5.patch}
                      patch -p1 < ${./jens-ideacentre-6.patch}

                      # Patch 7: the second USB MP lane is not populated on Purwa.
                      sed -i \
                        -e '/^\teusb6_repeater: redriver@4f {$/,/^\t};$/d' \
                        -e '/^\teusb6_reset_n: eusb6-reset-n-state {$/,/^\t};$/d' \
                        -e '/^&usb_mp_hsphy1 {$/,/^};$/d' \
                        -e '/^&usb_mp_qmpphy1 {$/,/^};$/d' \
                        "$commonDts"
                      sed -i '/^&usb_mp {$/,/^};$/ s/^\tstatus = "okay";$/\tstatus = "okay";\n\tphys = <\&usb_mp_hsphy0>, <\&usb_mp_qmpphy0>;\n\tphy-names = "usb2-0", "usb3-0";/' "$commonDts"

                      install -Dm644 ${./purwa-lenovo-ideacentre-mini-01q8x10.dts} \
                        arch/arm64/boot/dts/qcom/${ideacentreDtbName}.dts
                      printf '%s\n' \
                        'dtb-$(CONFIG_ARCH_QCOM) += purwa-lenovo-ideacentre-mini-01q8x10.dtb' \
                        >> arch/arm64/boot/dts/qcom/Makefile
                    '';

                    configurePhase = ''
                      runHook preConfigure

                      mkdir build
                      chmod u+rwx build
                      export buildRoot="$(pwd)/build"
                      cp -v ${kernel.configfile} "$buildRoot/.config"
                      chmod u+rw "$buildRoot/.config"

                      sed -i -E \
                        -e '/^(CONFIG_RUST|CONFIG_DEBUG_INFO_BTF|CONFIG_DEBUG_INFO_BTF_MODULES)=/d' \
                        -e '/^# CONFIG_(RUST|DEBUG_INFO_BTF|DEBUG_INFO_BTF_MODULES) is not set$/d' \
                        "$buildRoot/.config"
                      printf '%s\n' \
                        '# CONFIG_RUST is not set' \
                        '# CONFIG_DEBUG_INFO_BTF is not set' \
                        '# CONFIG_DEBUG_INFO_BTF_MODULES is not set' \
                        >> "$buildRoot/.config"

                      make "''${makeFlags[@]}" olddefconfig
                      make "''${makeFlags[@]}" prepare
                      actualModDirVersion="$(cat "$buildRoot/include/config/kernel.release")"
                      if [ "$actualModDirVersion" != "${kernel.modDirVersion}" ]; then
                        echo "Error: kernel version changed unexpectedly: $actualModDirVersion"
                        exit 1
                      fi

                      cd "$buildRoot"
                    '';

                    buildPhase = ''
                      runHook preBuild

                      cd ..
                      make "''${makeFlags[@]}" O="$buildRoot" \
                        qcom/${ideacentreDtbName}.dtb \
                        DTC_FLAGS=-@

                      runHook postBuild
                    '';

                    preInstall = "";
                    installPhase = ''
                      runHook preInstall

                      install -Dm644 \
                        "$buildRoot/arch/arm64/boot/dts/qcom/${ideacentreDtbName}.dtb" \
                        "$out/dtbs/qcom/${ideacentreDtbName}.dtb"

                      runHook postInstall
                    '';
                    postInstall = "";
                    preFixup = "";
                  });
                  ideacentreFirmware = pkgs.runCommand "ideacentre-jens-dsp-firmware" { } ''
                    mkdir -p "$out/lib/firmware"
                    cp -r ${./firmware}/qcom "$out/lib/firmware/"
                  '';
                in
                {
                imports = [
                  (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
                ];
                nixpkgs = {
                  overlays = [
                    module.overlays.aarch64-linux
                  ];
                };

                networking.hostName = "nixos-installer";
                environment.systemPackages = with pkgs; [
                  git
                  vim
                  curl
                ];

                isoImage = {
                  makeEfiBootable = true;
                  contents = [
                    {
                      source = "${ideacentreDtb}/dtbs/qcom/${ideacentreDtbName}.dtb";
                      target = "/boot/dtbs/qcom/${ideacentreDtbName}.dtb";
                    }
                  ];
                };
                hardware = {
                  deviceTree.enable = true;
                  enableRedistributableFirmware = true;
                  firmware = [ ideacentreFirmware ];
                };
                boot = {
                  kernelPackages = pkgs.linuxPackages_latest;
                  kernelPatches = [
                    {
                      name = "jens-purwa-usb-config";
                      patch = null;
                      structuredExtraConfig = {
                        USB_DWC3_ULPI = lib.kernel.yes;
                        USB_XHCI_PLATFORM = lib.kernel.module;
                        USB_STORAGE = lib.kernel.module;
                        USB_DWC3 = lib.kernel.module;
                        USB_DWC3_QCOM = lib.kernel.module;
                        USB_HID = lib.kernel.module;
                        HID_GENERIC = lib.kernel.module;
                        REGMAP_SPMI = lib.kernel.module;
                        SPMI = lib.kernel.module;
                        SPMI_MSM_PMIC_ARB = lib.kernel.module;
                        PINCTRL_QCOM_SPMI_PMIC = lib.kernel.module;
                        MFD_SPMI_PMIC = lib.kernel.module;
                      };
                    }
                  ];
                  kernelParams = [
                    # Boot parameters used by Jens's Purwa GRUB entry.
                    "stubble.dtb_override=false"
                    "clk_ignore_unused"
                    "pd_ignore_unused"
                    "regulator_ignore_unused"
                    "efi=noruntime"
                    "id_aa64mmfr0.ecv=1"
                    "arm64.nopauth"
                    "modprobe.blacklist=gpi"
                    "loglevel=8"
                    "console=tty0"
                    "rd.systemd.show_status=1"
                    "rd.systemd.log_level=debug"
                    "rd.system.log_target=console"
                    "udev.log-priority=debug"
                  ];
                  kernelModules = [
                    "dwc3_qcom"
                    "dwc3"
                    "xhci_hcd"
                    "xhci_plat_hcd"
                    "phy_qcom_qmp_usb"
                    "spmi_pmic_arb"
                    "qcom_spmi_pmic"
                    "regmap_spmi"
                    "pinctrl_spmi_gpio"
                    "usb_storage"
                    "uas"
                    "usbhid"
                    "hid_generic"
                  ];
                  initrd.systemd.enable = true;
                  initrd.extraFirmwarePaths = [
                    "qcom/x1e80100/adsp.mbn"
                    "qcom/x1e80100/adsp_dtb.mbn"
                    "qcom/x1e80100/cdsp.mbn"
                    "qcom/x1e80100/cdsp_dtb.mbn"
                    "qcom/x1e80100/gen70500_zap.mbn"
                    "qcom/x1e80100/qupv3fw.elf"
                    "qcom/x1p42100/gen71500_zap.mbn"
                  ];
                  initrd.services.udev.rules = ''
                    ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", IMPORT{builtin}="blkid", ENV{ID_FS_TYPE}=="iso9660", ENV{ID_FS_LABEL}=="${config.isoImage.volumeID}", SYMLINK+="disk/by-label/${config.isoImage.volumeID}"
                  '';
                  initrd.systemd.services.ideacentre-iso-device = {
                    description = "Find the IdeaCentre installer ISO and print DTB diagnostics";
                    wantedBy = [ "sysroot-iso.mount" ];
                    before = [ "sysroot-iso.mount" ];
                    wants = [ "systemd-modules-load.service" "systemd-udev-trigger.service" "systemd-vconsole-setup.service" ];
                    after = [ "systemd-modules-load.service" "systemd-udev-trigger.service" "systemd-vconsole-setup.service" ];
                    unitConfig.DefaultDependencies = false;
                    serviceConfig = {
                      Type = "oneshot";
                      StandardOutput = "console";
                      StandardError = "console";
                    };
                    script = ''
                      exec > /dev/console 2>&1
                      echo "IdeaCentre initrd diagnostic service started"

                      model="unknown"
                      if [ -r /proc/device-tree/model ]; then
                        model=$(${pkgs.coreutils}/bin/tr -d '\000' < /proc/device-tree/model)
                      fi
                      echo "IdeaCentre initrd DTB model: $model"

                      /bin/udevadm settle --timeout=5 || true

                      device=""
                      for attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
                        for candidate in /dev/sd* /dev/mmcblk* /dev/nvme*; do
                          if [ -b "$candidate" ]; then
                            type=$(${pkgs.util-linux}/bin/blkid -o value -s TYPE "$candidate" 2>/dev/null || true)
                            label=$(${pkgs.util-linux}/bin/blkid -o value -s LABEL "$candidate" 2>/dev/null || true)
                            echo "IdeaCentre initrd block device: $candidate type=''${type:-unknown} label=''${label:-unknown}"
                            if [ "$type" = "iso9660" ]; then
                              device="$candidate"
                              break 2
                            fi
                          fi
                        done
                        if [ -n "$device" ]; then
                          break
                        fi
                        ${pkgs.coreutils}/bin/sleep 1
                      done

                      echo "IdeaCentre initrd ISO device: ''${device:-not-found}"
                      if [ -n "$device" ]; then
                        ${pkgs.coreutils}/bin/mkdir -p /dev/disk/by-label
                        ${pkgs.coreutils}/bin/ln -sfn "$device" "/dev/disk/by-label/${config.isoImage.volumeID}"
                        echo "IdeaCentre initrd ISO link: /dev/disk/by-label/${config.isoImage.volumeID} -> $device"
                      fi
                    '';
                  };
                  initrd.kernelModules = [
                    # Storage
                    "nvme"
                    "isofs"
                    "squashfs"
                    "loop"

                    # Platform communication (SCMI mailbox chain)
                    "qrtr"
                    "qcom_glink_smem"
                    "pmic_glink"
                    "qcom_cpucp_mbox"
                    "qcom_q6v5_pas"

                    # PHY drivers
                    "phy_qcom_qmp_pcie"
                    "phy_qcom_qmp_combo"
                    "phy_qcom_qmp_usb"
                    "phy_qcom_eusb2_repeater"
                    "phy_snps_eusb2"

                    # SPMI/PMIC support used by the USB and Type-C nodes
                    "spmi_pmic_arb"
                    "qcom_spmi_pmic"
                    "regmap_spmi"
                    "pinctrl_spmi_gpio"

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
                    "dwc3_qcom"
                    "dwc3"
                    "xhci_hcd"
                    "xhci_plat_hcd"

                    "usb_storage"
                    "sd_mod"

                    # HID
                    "usbhid"
                    "hid_generic"

                    # Input devices (keyboard for password fallback)
                    "i2c_hid_of"
                    "i2c_qcom_geni"
                  ];

                  loader.grub = {
                    enable = true;
                    efiInstallAsRemovable = true;
                    extraPerEntryConfig = "devicetree /boot/dtbs/qcom/${ideacentreDtbName}.dtb";
                  };
                };
                boot.supportedFilesystems = { zfs = nixpkgs.lib.mkForce false; };
                nix.settings.experimental-features = [ "nix-command" "flakes" ];
                }
              )
            ];
          };
        };
      homeConfigurations = lib.forAllHomeManagerHosts (name: config:
        let
          system = config.system;
          username = lib.getUsername name;
        in home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [
            module.nixosModules.home-manager
            agenix.homeManagerModules.default
            config.config
            {
              nixpkgs.overlays = [
                module.overlays."${system}"
                (import ./overlay/dummy.nix)
              ];

              home = {
                stateVersion = "26.05";
                username = username;
                homeDirectory = "/home/${username}";
              };
              programs.zsh.envExtra = "PATH=/home/mertsas/.nix-profile/bin:$PATH";

              # programs.tmux.shell = "$SHELL";
              targets.genericLinux.enable = true;
              nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
                "google-chrome"
                "zoom"
                "webex"
                "spotify"
                "steam"
                "steam-original"
                "steam-unwrapped"
              ];
            }
          ];
        });
    };
    nixConfig = {
      substituters = [
        "https://cache.nixos.org"
        "https://cache.martiert.com"
      ];
    };
}

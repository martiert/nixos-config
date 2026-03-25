{
  description = "images for creation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
              ({ modulesPath, config, pkgs, ... }: {
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
                      source = "${config.boot.kernelPackages.kernel.outPath}/dtbs/qcom/x1p42100-lenovo-ideacentre-x-gen10.dtb";
                      target = "/boot/dtbs/qcom/x1p42100-lenovo-ideacentre-x-gen10.dtb";
                    }
                  ];
                };
                hardware = {
                  deviceTree = {
                    enable = true;
                    name = "qcom/x1p42100-lenovo-ideacentre-x-gen10.dtb";
                  };
                  firmware = [
                    pkgs.lenovo-t14s-firmware
                  ];
                  enableRedistributableFirmware = true;
                };
                boot = {
                  kernelPackages = pkgs.linuxPackagesFor (pkgs.t14s-kernel.overrideAttrs (old: {
                    patches = old.patches or [] ++ [ ./x1p42100-lenovo-ideacentre-x-gen10.patch ];
                  }));
                  kernelParams = [
                    "clk_ignore_unused"
                    "pd_ignore_unused"
                  ];
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

                  loader.grub = {
                    enable = true;
                    efiInstallAsRemovable = true;
                    extraPerEntryConfig = "devicetree /boot/dtbs/qcom/x1p42100-lenovo-ideacentre-x-gen10.dtb";
                  };
                };
                nix.settings.experimental-features = [ "nix-command" "flakes" ];
              })
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

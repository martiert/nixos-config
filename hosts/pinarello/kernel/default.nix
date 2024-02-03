let
  patches = [
    ./0001-arm64-dts-rk3399-pinebook-pro-Fix-USB-PD-charging.patch
    ./0007-ASoC-codec-es8316-DAC-Soft-Ramp-Rate-is-just-a-2-bit.patch
    ./0002-arm64-dts-rk3399-pinebook-pro-Improve-Type-C-support.patch
    ./0008-arm64-dts-rk3399-pinebook-pro-Fix-codec-frequency-af.patch
    ./0003-arm64-dts-rk3399-pinebook-pro-Remove-redundant-pinct.patch
    ./0009-arm64-dts-rockchip-rk3399-pinebook-pro-Fix-VDO-displ.patch
    ./0004-arm64-dts-rk3399-pinebook-pro-Remove-unused-features.patch
    ./0010-arm64-dts-rockchip-rk3399-pinebook-pro-Add-sdr104-to.patch
    ./0005-arm64-dts-rk3399-pinebook-pro-Don-t-allow-usb2-phy-d.patch
    ./0011-arm64-dts-rockchip-rk3399-pinebook-pro-Disable-SD-ca.patch
    ./0006-arm64-dts-rockchip-rk3399-pinebook-pro-Support-both-.patch
  ];
  makePatch = p: {
    name = toString p;
    patch = p;
  };
in {
  boot.kernelPatches = map makePatch patches;
}

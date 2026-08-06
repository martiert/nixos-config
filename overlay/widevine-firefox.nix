# Widevine CDM integration for Firefox on ARM64 Linux systems
# Enables DRM content playback (Netflix, Disney+, Spotify, etc.) on aarch64-linux
final: prev:
let
  inherit (prev) lib stdenv;
in
{
  # Only apply Widevine integration to Linux ARM64 systems
}
// lib.optionalAttrs (stdenv.isLinux && stdenv.isAarch64) {
  wrapFirefox =
    browser: opts:
    let
      # Firefox preferences to enable DRM/Widevine
      extraPrefs = opts.extraPrefs or "" + ''
        // Widevine CDM configuration for DRM content
        lockPref("media.gmp-widevinecdm.version", "system-installed");
        lockPref("media.gmp-widevinecdm.visible", true);
        lockPref("media.gmp-widevinecdm.enabled", true);
        lockPref("media.gmp-widevinecdm.autoupdate", false);
        lockPref("media.eme.enabled", true);
        lockPref("media.eme.encrypted-media-encryption-scheme.enabled", true);
      '';

      # Paths to Widevine CDM files from nixpkgs
      widevineCdmDir = "${final.widevine-cdm}/share/google/chrome/WidevineCdm";
      widevineOutDir = "$out/gmp-widevinecdm/system-installed";
    in
    (prev.wrapFirefox browser (opts // { inherit extraPrefs; })).overrideAttrs (previousAttrs: {
      buildCommand = previousAttrs.buildCommand + ''
        # Create Widevine directory structure
        mkdir -p "${widevineOutDir}"
        
        # Symlink Widevine library and manifest
        ln -s "${widevineCdmDir}/_platform_specific/linux_arm64/libwidevinecdm.so" "${widevineOutDir}/libwidevinecdm.so"
        ln -s "${widevineCdmDir}/manifest.json" "${widevineOutDir}/manifest.json"
        
        # Set MOZ_GMP_PATH environment variable for Firefox
        wrapProgram "$oldExe" --set MOZ_GMP_PATH "${widevineOutDir}"
      '';
    });
}

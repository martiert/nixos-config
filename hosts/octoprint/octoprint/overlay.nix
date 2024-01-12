self: super: {
  octoprint = super.octoprint.override {
      packageOverrides = self: super: {
        firmwareupdater = self.callPackage ./firmwareupdater.nix {};
        flashforge = self.callPackage ./flashforge.nix {};
      };
  };
}

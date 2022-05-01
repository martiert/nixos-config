self: super: {
  octoprint = (super.callPackage ./default.nix {}).override {
      packageOverrides = self: super: {
        firmwareupdater = let
            name = "FirmwareUpdater";
          in self.buildPythonPackage rec {
            pname = "OctoPrintPlugin-${name}";
            version = "1.13.2";
            propagatedBuildInputs = [
              self.octoprint
            ];

            src = fetchTarball {
              url = "https://github.com/OctoPrint/OctoPrint-${name}/archive/refs/tags/${version}.tar.gz";
              sha256 = "0zjy2mr2h44n14f66336lzf9ksx0yb6l678l81vc9rwxl8p56zrm";
            };

            doCheck = false;
          };
      };
  };
}

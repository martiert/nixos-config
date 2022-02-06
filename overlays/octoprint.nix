self: super: {
  octoprint = super.octoprint.override {
      packageOverrides = self: super: {
        firmwareupdater = let
            version = "1.13.0";
            name = "FirmwareUpdater";
          in self.buildPythonPackage {
            pname = "OctoPrintPlugin-${name}";
            version = "${version}";
            propagatedBuildInputs = [
              self.octoprint
            ];

            src = fetchTarball {
              url = "https://github.com/OctoPrint/OctoPrint-${name}/archive/refs/tags/${version}.tar.gz";
              sha256 = "1b3v32apzj51pwh5jh11a0gxf6hj6xlp6lirlgqwjkvx04x6q955";
            };

            doCheck = false;
          };
      };
  };
}

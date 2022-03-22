self: super: {
  octoprint = super.octoprint.override {
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
              sha256 = "0nzlpf7868cs7grcrs21wkak94rxj0ay1s2bggywlkc8mmp9kf3x";
            };

            doCheck = false;
          };
      };
  };
}

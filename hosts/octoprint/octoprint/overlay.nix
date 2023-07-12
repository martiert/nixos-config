self: super: {
  octoprint = super.octoprint.override {
      packageOverrides = self: super: {
        firmwareupdater = let
            name = "FirmwareUpdater";
          in self.buildPythonPackage rec {
            pname = "OctoPrintPlugin-${name}";
            version = "1.13.3";
            propagatedBuildInputs = [
              self.octoprint
            ];

            src = fetchTarball {
              url = "https://github.com/OctoPrint/OctoPrint-${name}/archive/refs/tags/${version}.tar.gz";
              sha256 = "02x8bqi2s2fa57j5sz3dizzmrck6j5hh7nn40svrzr71yyqxx5pd";
            };

            doCheck = false;
          };
      };
  };
}

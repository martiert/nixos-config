{ tmuxp, fetchPypi, ... }:

tmuxp.overrideAttrs (old: rec {
  version = "1.34.0";
  src = fetchPypi {
    pname = old.pname;
    version = version;
    hash = "sha256-G93YtgXo4li+tLWKgJFaxx4Ax4sK4F+vK6M3WTXIeiU=";
  };
})

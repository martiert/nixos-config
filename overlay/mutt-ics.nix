{ lib
, stdenv
, python3Packages
, fetchFromGitHub
}:

python3Packages.buildPythonApplication rec {
  pname = "mutt-ics";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "dmedvinsky";
    repo = pname;
    rev = "ac54116be429cb92230f03ec8d3cdbdceaf8f008";
    sha256 = "sha256-6NYs/JpcOhkeCGqm9pEFJjFBbA0+S1X7dfbggyZJ/t4=";
    forceFetchGit = true;
  };

  propagatedBuildInputs = [
    python3Packages.icalendar
    python3Packages.python-dateutil
  ];

  meta = with lib; {
    description = "Mutt-ics";
    homepage = "https://github.com/dmedvinsky/mutt-ics";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [{
      name = "Martin Ertsås";
      email = "martiert@gmail.com";
    }];
  };
}

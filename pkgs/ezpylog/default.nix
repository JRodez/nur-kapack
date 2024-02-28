{lib, python3Packages, fetchFromGitHub}:
python3Packages.buildPythonPackage rec {
  pname = "ezpylog";
  version = "2.1.1";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "JRodez";
    name = "ezpylog";
    repo = pname;
    rev = "38e8dc2";
    sha256 = "sha256-VWKThK8+mZ7f+Aii40vLjaLOH8rAjxx7PuadC3q01ZM=";
  };

  propagatedBuildInputs = with python3Packages; [

  ];

  # FIXME: tests are not passing and need to be refactored...
  doCheck = false;

  meta = with lib; {
    description = "ezpylog is a minimalistic and easy to use python logger";
    homepage    = https://github.com/JRodez/ezpylog;
    platforms   = python3Packages.debugpy.meta.platforms; # TODO: be more precise if possible
    license = licenses.gpl3;
    longDescription = ''
        ezpylog is a minimalistic and easy to use python logger
    '';
    broken = false;
  };
}

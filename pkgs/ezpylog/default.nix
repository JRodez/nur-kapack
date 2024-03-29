{lib, python3Packages, fetchFromGitHub}:
python3Packages.buildPythonPackage rec {
  pname = "ezpylog";
  version = "2.2.0";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "JRodez";
    name = "ezpylog";
    repo = pname;
    rev = "4374c01";
    sha256 = "sha256-RH5uDjXXArT39wB1ZRMVgUILqBUUTMoi8lu3Cp+GlYU=";
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

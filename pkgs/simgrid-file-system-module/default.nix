{
  stdenv,
  fetchFromGitHub,
  lib,
  ninja,
  cmake,
  pkg-config,
  simgrid,
  boost,
  gtest,
  doCheck ? true,

}:
stdenv.mkDerivation rec {
  inherit doCheck;

  pname = "simgrid-fsmod";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "simgrid";
    repo = "file-system-module";
    rev = "v${version}";
    sha256 = "sha256-Ie6nDdtSLfNSDmg8QA0rsZWSecO0GZYsJ2EJdJ7hBsU=";
  };

  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gtest
  ];
  buildInputs = [
    simgrid
    boost
  ];
  cmakeFlags = [
    "-DSimGrid_PATH=${simgrid}"
    "-G Ninja"
  ];
  checkPhase = ''
    ninja unit_tests
    ./unit_tests --gtest_filter=-JBODStorageTest.ReadWriteRAID6
  '';
}

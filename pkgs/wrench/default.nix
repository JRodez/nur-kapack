{
  lib,
  debug ? false,
  doCheck ? true,
  useBatsched ? false,
  simgrid,
  boost,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  git,
  gtest,
  simgrid-fsmod,
  gmp,
  cppzmq,
  nlohmann_json,
}:
let fsmod = simgrid-fsmod.override {
  inherit simgrid boost;
};
in
stdenv.mkDerivation rec {
  inherit debug doCheck;
  pname = "wrench";
  version = "2.5";
  src = fetchFromGitHub {
    owner = "wrench-project";
    repo = "wrench";
    rev = "v${version}";
    sha256 = "sha256-bcX7tA/Gl0ZqaYMUGFAu4Ts8zmer9A73mE8QjAF82NI=";
  };

  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  nativeBuildInputs =  [
    # meson
    ninja
    cmake
    pkg-config
    gtest
  ];

  buildInputs = [
    fsmod
    simgrid
    gmp
    nlohmann_json
    boost
    cppzmq
  ];

  cmakeFlags = [
    "-DSimGrid_PATH=${simgrid}"
    "-DENABLE_BATSCHED=${if useBatsched then "on" else "off"}"
    "-G Ninja"
  ];

  CXXFLAGS = if debug then "-O0" else "-O3";
  hardeningDisable = if debug then [ "fortify" ] else [ ];

  dontStrip = debug;

  meta = with lib; {
    # description = "Batsim C++ scheduling algorithms for service mapping .";
    # longDescription = "A set of scheduling algorithms for Batsim (and WRENCH).";
    homepage = "";
    platforms = platforms.all;
    license = licenses.free;
    broken = false;
  };
}

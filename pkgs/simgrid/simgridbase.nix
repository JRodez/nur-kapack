{
  stdenv,
  lib,
  fetchFromGitLab,
  cmake,
  perl,
  python3,
  boost,
  version,
  sha256 ? "",
  doCheck ? true,
  fortranSupport ? false,
  gfortran,
  buildDocumentation ? false,
  fig2dev,
  ghostscript,
  doxygen,
  buildJavaBindings ? false,
  openjdk,
  buildPythonBindings ? false,
  python3Packages,
  modelCheckingSupport ? false,
  libunwind,
  libevent,
  elfutils, # Inside elfutils: libelf and libdw
  bmfSupport ? true,
  eigen,
  minimalBindings ? false,
  debug ? false,
  optimize ? (!debug),
  moreTests ? false,
  withoutBin ? false,
  withoutBoostPropagation ? false,
}:

with lib;

let
  optionOnOff = option: if option then "on" else "off";
in

stdenv.mkDerivation rec {
  inherit version doCheck;
  pname = "simgrid";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = pname;
    repo = pname;
    sha256 = sha256;
    rev = "v${version}";
  };

  propagatedBuildInputs = optionals (!withoutBoostPropagation) [ boost ];
  nativeBuildInputs =
    [
      cmake
      perl
      python3
    ]
    ++ optionals withoutBoostPropagation [ boost ]
    ++ optionals fortranSupport [ gfortran ]
    ++ optionals buildJavaBindings [ openjdk ]
    ++ optionals buildPythonBindings [ python3Packages.pybind11 ]
    ++ optionals buildDocumentation [
      fig2dev
      ghostscript
      doxygen
    ]
    ++ optionals bmfSupport [ eigen ]
    ++ optionals modelCheckingSupport [
      libunwind
      libevent
      elfutils
    ];

  outputs = [ "out" ] ++ optionals buildPythonBindings [ "python" ];

  # "Release" does not work. non-debug mode is Debug compiled with optimization
  cmakeBuildType = "Debug";
  cmakeFlags = [
    (cmakeBool "enable_documentation" buildDocumentation)
    (cmakeBool "enable_java" buildJavaBindings)
    (cmakeBool "enable_python" buildPythonBindings)
    (cmakeFeature "SIMGRID_PYTHON_LIBDIR" "./") # prevents CMake to install in ${python3} dir
    (cmakeBool "enable_msg" buildJavaBindings)
    (cmakeBool "enable_fortran" fortranSupport)
    (cmakeBool "enable_model-checking" modelCheckingSupport)
    (cmakeBool "enable_ns3" false)
    (cmakeBool "enable_lua" false)
    (cmakeBool "enable_lib_in_jar" false)
    (cmakeBool "enable_maintainer_mode" false)
    (cmakeBool "enable_mallocators" true)
    (cmakeBool "enable_debug" true)
    (cmakeBool "enable_smpi" true)
    (cmakeBool "minimal-bindings" minimalBindings)
    (cmakeBool "enable_smpi_ISP_testsuite" moreTests)
    (cmakeBool "enable_smpi_MPICH3_testsuite" moreTests)
    (cmakeBool "enable_compile_warnings" false)
    (cmakeBool "enable_compile_optimizations" optimize)
    (cmakeBool "enable_lto" optimize)
    # RPATH of binary /nix/store/.../bin/... contains a forbidden reference to /build/
    (cmakeBool "CMAKE_SKIP_BUILD_RPATH" optimize)
  ];
  makeFlags = optional debug "VERBOSE=1";

  # needed to run tests and to ensure correct shabangs in output scripts
  preBuild = ''
    patchShebangs ..
  '';

  # needed by tests (so libsimgrid.so is found)
  preConfigure = ''
    export LD_LIBRARY_PATH="$PWD/build/lib"
  '';

  preCheck = ''
    # prevent the execution of tests known to fail
    cat <<EOW >CTestCustom.cmake
    SET(CTEST_CUSTOM_TESTS_IGNORE smpi-replay-multiple)
    EOW

    # make sure tests are built in parallel (this can be long otherwise)
    make tests -j $NIX_BUILD_CORES
  '';

  postInstall =
    lib.optionalString withoutBin ''
      # remove bin from output if requested.
      # having a specific bin output would be cleaner but it does not work currently (circular references)
      rm -rf $out/bin
      rm -f $out/lib/simgrid/smpimain
      rm -f $out/lib/simgrid/smpireplaymain
    ''
    + lib.optionalString buildPythonBindings ''
      # manually install the python binding if requested.
      mkdir -p $python/lib/python${lib.versions.majorMinor python3.version}/site-packages/
      cp ./lib/simgrid.cpython*.so $python/lib/python${lib.versions.majorMinor python3.version}/site-packages/
    '';

  # improve debuggability if requested
  hardeningDisable = lib.optionals debug [ "fortify" ];
  dontStrip = debug;

  meta = {
    description = "Framework for the simulation of distributed applications";
    longDescription = ''
      SimGrid is a toolkit that provides core functionalities for the
      simulation of distributed applications in heterogeneous distributed
      environments.  The specific goal of the project is to facilitate
      research in the area of distributed and parallel application
      scheduling on distributed computing platforms ranging from simple
      network of workstations to Computational Grids.
    '';
    homepage = "https://simgrid.org/";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      mickours
      mpoquet
    ];
    platforms = platforms.all;
    broken = stdenv.isDarwin;
  };
}

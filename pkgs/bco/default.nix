{ stdenv, lib, python3, python3Packages, fetchFromGitHub }:
stdenv.mkDerivation rec {
  pname = "BetterCompilerOutput";
  version = "1.1.0";
  name = "${pname}-${version}";

  # src = fetchFromGitHub {
  #   owner = "JRodez";
  #   name = "Better Compiler Output";
  #   repo = pname;
  #   rev = "4374c01";
  #   sha256 = "sha256-RH5uDjXXArT39wB1ZRMVgUILqBUUTMoi8lu3Cp+GlYU=";
  # };

  # src = fetchTarball "https://github.com/JRodez/BetterCompilerOutput/archive/refs/heads/master.tar.gz";


  src = ./src;
  preInstall = ''
    mkdir -p $out/bin
  '';

  postInstall = ''
    install -Dm755 ${./src/bco.py} $out/bin/bco
  '';

  propagatedBuildInputs = [
    python3
  ];

  # FIXME: tests are not passing and need to be refactored...
  doCheck = false;

  meta = with lib; {
    description = "bco is a output wrapper for compilers that makes it easier to read and understand the output of the compiler";
    homepage = https://github.com/JRodez/BetterCompilerOutput;
    platforms = python3Packages.debugpy.meta.platforms; # TODO: be more precise if possible
    license = licenses.gpl3;
    longDescription = ''
      bco is a output wrapper for compilers that makes it easier to read and understand the output of the compiler.
      It does this by colorizing the output and adding additional information to the output.
      It is designed to be used with any compiler that outputs to the terminal.
    '';
    broken = false;
  };
}

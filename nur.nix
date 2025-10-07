# If called without explicitly setting the 'pkgs' arg, a pinned nixpkgs version is used by default.
{
  pkgs,
  debug ? false,
}:
let

in
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  # modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  inherit pkgs;

  # glibc-batsky = pkgs.glibc.overrideAttrs (attrs: {
  #   meta.broken = true;
  #   patches = attrs.patches ++ [
  #     ./pkgs/glibc-batsky/clock_gettime.patch
  #     ./pkgs/glibc-batsky/gettimeofday.patch
  #   ];
  #   postConfigure = ''
  #     export NIX_CFLAGS_LINK=
  #     export NIX_LDFLAGS_BEFORE=
  #     export NIX_DONT_SET_RPATH=1
  #     unset CFLAGS
  #     makeFlagsArray+=("bindir=$bin/bin" "sbindir=$bin/sbin" "rootsbindir=$bin/sbin" "--quiet")
  #   '';
  # });

  latest_commit =
    repos_root:
    let
      gitdir = repos_root + "/.git";
      head_path =
        gitdir
        + ("/" + builtins.head (builtins.match "^ref: (.*)\n$" (builtins.readFile (gitdir + /HEAD))));
    in
    builtins.head (builtins.match "^(.*)\n$" (builtins.readFile head_path));

  libpowercap = pkgs.callPackage ./pkgs/libpowercap { };

  llvmStdenvBase = (
    {
      llvmPackages ? pkgs.llvmPackages_latest,
    }:
    llvmPackages.stdenv.override {
      cc = llvmPackages.stdenv.cc.override {
        bintools = llvmPackages.bintools;
      };
    }
    // {
      inherit llvmPackages;
    }
  );
  llvmStdenv = llvmStdenvBase { };

  haskellPackages = import ./pkgs/haskellPackages { inherit pkgs; };

  alumet = pkgs.callPackage ./pkgs/alumet { };

  batsched-140 = pkgs.callPackage ./pkgs/batsched/batsched140.nix {
    inherit loguru redox debug;
    intervalset = intervalsetlight;
  };
  batsched = batsched-140;

  batexpe = pkgs.callPackage ./pkgs/batexpe { };

  batsim-410 = pkgs.callPackage ./pkgs/batsim/batsim410.nix {
    inherit redox debug;
    simgrid = simgrid-334light;
    intervalset = intervalsetlight;
  };

  batsim-420 = pkgs.callPackage ./pkgs/batsim/batsim420.nix {
    inherit redox debug;
    simgrid = simgrid-334light;
    intervalset = intervalsetlight;
  };

  batsim-420-sg335 = pkgs.callPackage ./pkgs/batsim/batsim420.nix {
    inherit redox debug;
    simgrid = simgrid-335light;
    intervalset = intervalsetlight;
  };

  batsim-420-sg335f = pkgs.callPackage ./pkgs/batsim/batsim420.nix {
    inherit redox debug;
    simgrid = simgrid-335;
    intervalset = intervalsetlight;
  };

  batsim-420-iot =
    (pkgs.callPackage ./pkgs/batsim/batsim420-2024-07.nix {
      inherit redox debug;
      simgrid = simgrid-335-iot;
      intervalset = intervalsetlight;
    }).overrideAttrs
      (oldAttrs: {
        name = "batsim-420-iot";
      });

  batsim = batsim-420-sg335f;
  batsim-docker = pkgs.callPackage ./pkgs/batsim/batsim-docker.nix { inherit batsim; };

  # elastisim = pkgs.callPackage ./pkgs/elastisim { };

  # batsky = pkgs.callPackage ./pkgs/batsky { };
  bco = pkgs.callPackage ./pkgs/bco { };
  cli11 = pkgs.callPackage ./pkgs/cli11 { };

  cgvg = pkgs.callPackage ./pkgs/cgvg { };

  cpp-driver = pkgs.callPackage ./pkgs/cpp-driver { };

  scylladb-cpp-driver = pkgs.callPackage ./pkgs/scylladb-cpp-driver { };

  bacnet-stack = pkgs.callPackage ./pkgs/bacnet-stack { };

  # colmet = pkgs.callPackage ./pkgs/colmet { inherit libpowercap; };

  # colmet-rs = pkgs.callPackage ./pkgs/colmet-rs { };

  # colmet-collector = pkgs.callPackage ./pkgs/colmet-collector { };

  # dcdb = pkgs.callPackage ./pkgs/dcdb { inherit scylladb-cpp-driver bacnet-stack mosquitto-dcdb; };

  distem = pkgs.callPackage ./pkgs/distem { };

  ear = pkgs.callPackage ./pkgs/ear { };

  enoslib = pkgs.callPackage ./pkgs/enoslib {
    inherit
      execo
      iotlabsshcli
      distem
      python-grid5000
      ;
  };

  evalys = pkgs.callPackage ./pkgs/evalys { inherit procset; };

  execo = pkgs.callPackage ./pkgs/execo { };

  ezpylog = pkgs.callPackage ./pkgs/ezpylog { };

  flower = pkgs.callPackage ./pkgs/flower { inherit iterators; };

  iotlabcli = pkgs.callPackage ./pkgs/iotlabcli { };
  iotlabsshcli = pkgs.callPackage ./pkgs/iotlabsshcli { inherit iotlabcli parallel-ssh; };

  # likwid = pkgs.callPackage ./pkgs/likwid { };

  # melissa = pkgs.callPackage ./pkgs/melissa { };
  # melissa-heat-pde = pkgs.callPackage ./pkgs/melissa-heat-pde { inherit melissa; };

  # npb = pkgs.callPackage ./pkgs/npb { };

  # go-swagger = pkgs.callPackage ./pkgs/go-swagger { };

  gocov = pkgs.callPackage ./pkgs/gocov { };

  # gocovmerge = pkgs.callPackage ./pkgs/gocovmerge { };

  intervalset = pkgs.callPackage ./pkgs/intervalset { };
  intervalsetlight = pkgs.callPackage ./pkgs/intervalset { withoutBoostPropagation = true; };

  iterators = pkgs.callPackage ./pkgs/iterators { };

  # kube-batch = pkgs.callPackage ./pkgs/kube-batch { };

  loguru = pkgs.callPackage ./pkgs/loguru { inherit debug; };

  procset = pkgs.callPackage ./pkgs/procset { };

  mosquitto-dcdb = pkgs.callPackage ./pkgs/mosquitto-dcdb { };

  nxc-cluster = pkgs.callPackage ./pkgs/nxc/cluster.nix { inherit execo; };
  nxc = nxc-cluster;

  oxidisched = pkgs.callPackage ./pkgs/oxidisched { };

  pybatsim-320 = pkgs.callPackage ./pkgs/pybatsim/pybatsim320.nix { inherit procset; };
  pybatsim-321 = pkgs.callPackage ./pkgs/pybatsim/pybatsim321.nix { inherit procset; };
  pybatsim-core-400 = pkgs.callPackage ./pkgs/pybatsim/core400.nix { inherit procset; };
  pybatsim-functional-400 = pkgs.callPackage ./pkgs/pybatsim/functional400.nix {
    pybatsim-core = pybatsim-core-400;
  };
  pybatsim = pybatsim-321;
  pybatsim-core = pybatsim-core-400;
  pybatsim-functional = pybatsim-functional-400;

  # python-mip = pkgs.callPackage ./pkgs/python-mip { };

  redox = pkgs.callPackage ./pkgs/redox { };

  # remote_pdb = pkgs.callPackage ./pkgs/remote-pdb { };

  # rt-tests = pkgs.callPackage ./pkgs/rt-tests { };

  # cigri = pkgs.callPackage ./pkgs/cigri { };

  # oar = pkgs.callPackage ./pkgs/oar { inherit procset pybatsim remote_pdb; };

  # oar2 = pkgs.callPackage ./pkgs/oar2 { };

  # oar3 = oar;

  # vl-convert-python = pkgs.callPackage ./pkgs/vl-convert-python { };

  simgrid-base = pkgs.callPackage ./pkgs/simgrid/simgridbase.nix;
  simgrid-327 = pkgs.callPackage ./pkgs/simgrid/simgrid327.nix { inherit debug; };
  simgrid-328 = pkgs.callPackage ./pkgs/simgrid/simgrid328.nix { inherit debug; };
  simgrid-329 = pkgs.callPackage ./pkgs/simgrid/simgrid329.nix { inherit debug; };
  simgrid-330 = pkgs.callPackage ./pkgs/simgrid/simgrid330.nix { inherit debug; };
  simgrid-331 = pkgs.callPackage ./pkgs/simgrid/simgrid331.nix { inherit debug; };
  simgrid-332 = pkgs.callPackage ./pkgs/simgrid/simgrid332.nix { inherit debug; };
  simgrid-334 = pkgs.callPackage ./pkgs/simgrid/simgrid334.nix { inherit debug; };

  simgrid-335 = simgrid-base {
    inherit debug;
    stdenv = llvmStdenv;
    version = "3.35";
    sha256 = "sha256-WaFANZiPfiN/utfNZbwyH5mxgJNWafPMCcL863V8w0g=";
  };

  simgrid-335-iot = pkgs.callPackage ./pkgs/simgrid/simgrid335iot.nix {
    inherit debug;
    stdenv = llvmStdenv;
  };

  # simgrid-335-iot = simgrid-335.overrideAttrs (oldAttrs: rec {
  #   version = "3.35iot";
  #   doCheck = false;
  #   src = pkgs.fetchFromGitHub {
  #     owner = "jrodez";
  #     repo = "simgrid";
  #     rev = "v${version}";
  #     sha256 = "sha256-rwgkH5QenvexI6S2qWg17BHCdAXz5/AKPLkDQfHf6hI=";
  #   };
  # });

  simgrid-3351-iot = simgrid-335-iot.overrideAttrs (oldAttrs: rec {
    version = "3.35iot";
    doCheck = false;
    src = pkgs.fetchFromGitHub {
      owner = "jrodez";
      repo = "simgrid";
      rev = "ddafba4";
      sha256 = "sha256-v4yirzhP7hL20AcCwWMkx916Fe5Zg+8o1A7jvcoj3Jo=";
    };
  });

  simgrid-3352-iot = simgrid-335-iot.overrideAttrs (oldAttrs: rec {
    version = "3.35iot";
    doCheck = false;
    stdenv = llvmStdenv;
    src = fetchTarball {
      url = "https://framagit.org/JRodez/simgrid/-/archive/36cd18feb5247f41c466d536b226d792a2446b0d/simgrid-36cd18feb5247f41c466d536b226d792a2446b0d.tar.gz";
      sha256 = "sha256:1m2rgrfdhnp6lpqz7k9cbwlxppp5px9ak9dxnqkn77hqgpg7gfy2";
    };
  });

  simgrid-336 = simgrid-base rec {
    inherit debug;
    stdenv = llvmStdenv;
    version = "3.36";
    sha256 = "sha256-7w4ObbMem1Y8Lh9MOcdCSEktTDRkvVKmKlS9adm15oE=";
  };

  simgrid-327light = simgrid-327.override {
    minimalBindings = true;
    withoutBin = true;
    withoutBoostPropagation = true;
  };
  simgrid-328light = simgrid-328.override {
    minimalBindings = true;
    withoutBin = true;
    withoutBoostPropagation = true;
  };
  simgrid-329light = simgrid-329.override {
    minimalBindings = true;
    withoutBin = true;
    withoutBoostPropagation = true;
  };
  simgrid-330light = simgrid-330.override {
    minimalBindings = true;
    withoutBin = true;
    withoutBoostPropagation = true;
    buildPythonBindings = false;
  };
  simgrid-331light = simgrid-331.override {
    minimalBindings = true;
    withoutBin = true;
    withoutBoostPropagation = true;
    buildPythonBindings = false;
  };
  simgrid-332light = simgrid-332.override {
    minimalBindings = true;
    withoutBin = true;
    withoutBoostPropagation = true;
    buildPythonBindings = false;
  };
  simgrid-334light = simgrid-334.override {
    minimalBindings = true;
    withoutBin = true;
    withoutBoostPropagation = true;
    buildPythonBindings = false;
  };
  simgrid-335light = simgrid-335.override {
    minimalBindings = true;
    withoutBin = true;
    withoutBoostPropagation = true;
    buildPythonBindings = false;
  };

  simgrid = simgrid-335;
  simgrid-light = simgrid-335light;

  # simgrid-fsmod = pkgs.callPackage ./pkgs/simgrid-file-system-module {
  #   inherit simgrid;
  #   stdenv = llvmStdenv;
  # };

  # Setting needed for nixos-19.03 and nixos-19.09
  # slurm-bsc-simulator =
  #   if pkgs ? libmysql then
  #     pkgs.callPackage ./pkgs/slurm-simulator { libmysqlclient = pkgs.libmysql; }
  #   else
  #     pkgs.callPackage ./pkgs/slurm-simulator { };
  # slurm-bsc-simulator-v17 = slurm-bsc-simulator;

  # #slurm-bsc-simulator-v14 = slurm-bsc-simulator.override { version="14"; };

  # slurm-multiple-slurmd = pkgs.slurm.overrideAttrs (oldAttrs: {
  #   configureFlags = oldAttrs.configureFlags ++ [
  #     "--enable-multiple-slurmd"
  #     "--enable-silent-rules"
  #   ];
  #   meta.platforms = pkgs.lib.lists.intersectLists pkgs.rdma-core.meta.platforms pkgs.ghc.meta.platforms;
  # });

  # slurm-front-end = pkgs.slurm.overrideAttrs (oldAttrs: {
  #   configureFlags = [
  #     "--enable-front-end"
  #     "--with-lz4=${pkgs.lz4.dev}"
  #     "--with-zlib=${pkgs.zlib}"
  #     "--sysconfdir=/etc/slurm"
  #     "--enable-silent-rules"
  #   ];
  #   meta.platforms = pkgs.lib.lists.intersectLists pkgs.rdma-core.meta.platforms pkgs.ghc.meta.platforms;
  # });

  snakemake = pkgs.snakemake;

  ssh-python = pkgs.callPackage ./pkgs/ssh-python { };
  ssh2-python = pkgs.callPackage ./pkgs/ssh2-python { };

  parallel-ssh = pkgs.callPackage ./pkgs/parallel-ssh { inherit ssh-python ssh2-python; };

  python-grid5000 = pkgs.callPackage ./pkgs/python-grid5000 { };

  # starpu = pkgs.callPackage ./pkgs/starpu { };

  wait-for-it = pkgs.callPackage ./pkgs/wait-for-it { };

  # wirerope = pkgs.callPackage ./pkgs/wirerope { };

  # wrench = pkgs.callPackage ./pkgs/wrench {
  #   inherit simgrid simgrid-fsmod;
  #   stdenv = llvmStdenv;
  # };
  # yamldiff = pkgs.callPackage ./pkgs/yamldiff { };
}

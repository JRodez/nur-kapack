# If called without explicitly setting the 'pkgs' arg, a pinned nixpkgs version is used by default.
{ pkgs ? (import (fetchTarball {
    name = "nixpkgs-a4b56f9"; # master 2024-07
    url = "https://github.com/NixOS/nixpkgs/archive/a4b56f9941b41ab6520767823dea941b6b9162eb.tar.gz";
    sha256 = "0sl8xhhzlka06bn0a15xyhjcvr9aa3qbqkyvaylrfdp30288017r";
  })) { }
, debug ? false
}:

let
  nur-pkgs = import ./nur.nix { inherit pkgs debug; };
  master-pkgs = rec {
    batsched-master = pkgs.callPackage ./pkgs/batsched/master.nix { inherit debug; intervalset = nur-pkgs.intervalsetlight; loguru = nur-pkgs.loguru; redox = nur-pkgs.redox; };

    batexpe-master = pkgs.callPackage ./pkgs/batexpe/master.nix { batexpe = nur-pkgs.batexpe; };

    batsim-master = pkgs.callPackage ./pkgs/batsim/master.nix { inherit debug; intervalset = nur-pkgs.intervalsetlight; redox = nur-pkgs.redox; simgrid = nur-pkgs.simgrid-light; };
    batsim-docker-master = pkgs.callPackage ./pkgs/batsim/batsim-docker.nix { batsim = batsim-master; };

    pybatsim-master = pkgs.callPackage ./pkgs/pybatsim/master.nix { pybatsim = nur-pkgs.pybatsim; };

    simgrid-master = pkgs.callPackage ./pkgs/simgrid/master.nix { simgrid = nur-pkgs.simgrid; };
    simgrid-light-master = pkgs.callPackage ./pkgs/simgrid/master.nix { simgrid = nur-pkgs.simgrid-light; };
  };
in
nur-pkgs // master-pkgs

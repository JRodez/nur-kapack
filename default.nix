# If called without explicitly setting the 'pkgs' arg, a pinned nixpkgs version is used by default.
{ pkgs ? (import (fetchTarball {
    name = "nixpkgs-f7e8132"; # 2024-02-??
    url = "https://github.com/NixOS/nixpkgs/archive/f7e8132daca31b1e3859ac0fb49741754375ac3d.tar.gz";
    sha256 = "0z57px1wqjm9z51ifc9b0fccp0a9w9sakm9c1ybvkib096gmlp0g";
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

{
  description = " My personal NUR repository";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      inherit (flake-utils.lib) eachSystem filterPackages;

    in
    eachSystem systems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # config.allowBroken = true; # FIXME
        };
      in
      rec {
        packages = (filterPackages system (import ./nur.nix { inherit pkgs; })) // rec {
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
        };
        devShells.default = pkgs.mkShell {
          buildInputs = with packages; [

            (pkgs.hello.override { stdenv = llvmStdenv; })

            snakemake
            bco
            batexpe
            ezpylog
            simgrid-3351-iot
            pkgs.hello
          ];
        };
        lib = import ./lib { inherit pkgs; };
      }
    )
    // {
      nixosModules = builtins.mapAttrs (name: path: import path) (import ./modules);
      overlay = import ./overlay.nix;
    };

  #   forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  # in
  # {
  #   legacyPackages = forAllSystems (system: import ./nur.nix {
  #     pkgs = import nixpkgs { inherit system; };
  #   });
  #   packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
  #   lib = forAllSystems (system: import ./lib { inherit pkgs; });
  #   nixosModules =
  #     builtins.mapAttrs (name: path: import path) (import ./modules);
  #   overlay = import ./overlay.nix;

  # };
  # in
  #  eachSystem systems (system:
  #   {
  #     packages = (filterPackages system );
  #     lib = import ./lib { inherit pkgs; };
  #   }) // {
}

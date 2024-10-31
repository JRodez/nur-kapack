{
  description = " My personal NUR repository";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

    in
    {
      legacyPackages = forAllSystems (system: import ./nur.nix {
        pkgs = import nixpkgs { inherit system; };
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      
      nixosModules =
        builtins.mapAttrs (name: path: import path) (import ./modules);
      overlay = import ./overlay.nix;

    };
  # in
  #  eachSystem systems (system:
  #   {
  #     packages = (filterPackages system );
  #     lib = import ./lib { inherit pkgs; };
  #   }) // {
}

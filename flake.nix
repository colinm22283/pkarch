{
  description = "PKArch Developement Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        riscvPkgs = pkgs.pkgsCross.riscv32-embedded;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.verilator
            pkgs.gtkwave

            riscvPkgs.buildPackages.binutils
          ];
        };
      });
}


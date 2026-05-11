{
  description = "PKArch Developement Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }: let 
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.x86_64-linux.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        gcc
        gdb
        gnumake
        pkg-config

        vulkan-headers
        vulkan-loader
        vulkan-validation-layers

        shaderc

        freeglut
        glfw
        glm
      ];
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        binutils
      ];
    };
  };
}


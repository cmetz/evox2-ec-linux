{
  description = "DevShell for the evo-x2_ec kernel module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        kernelPackages = pkgs.linuxPackages_latest;
      in
      {
        devShells.default = pkgs.mkShell {
          name = "evo-x2_ec-devshell";

          packages = with pkgs; [
            gcc
            gnumake
            bc
            cpio
            elfutils
            kernelPackages.kernel.dev
            bear
          ];

          shellHook = ''
            export KERNEL_BUILD=$(find ${kernelPackages.kernel.dev}/lib/modules -type d -name build | head -n1)
            echo "✅ KERNEL_BUILD set to: $KERNEL_BUILD"
          '';

        };
      }
    );
}

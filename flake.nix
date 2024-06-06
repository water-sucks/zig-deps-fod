{
  description = "Fixed-output derivation for fetching Zig dependencies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          name = "zig-deps-fod-shell";
          packages = with pkgs; [zig];
        };
      };
    };
}

{
  description = "An example project that uses Zig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-compat.url = "github:edolstra/flake-compat";

    zig-deps-fod.url = "../.";
  };

  outputs = {
    nixpkgs,
    zig-deps-fod,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          name = "example";
          packages = [pkgs.zig];
        };

        packages.default = let
          inherit (pkgs) stdenv zig;
          inherit (zig-deps-fod.lib) fetchZigDeps;

          pname = "example";
          version = "0.0.1";
          src = ./.;

          deps = fetchZigDeps {
            inherit pname version src stdenv zig;
            hash = "sha256-Z9dWPmAfnRDPljYGxp67whZZSeu4oAqqCN0Nax3oVOM=";
          };
        in
          stdenv.mkDerivation {
            inherit pname version src;

            postPatch = ''
              ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
              export ZIG_GLOBAL_CACHE_DIR

              ln -s ${deps} "$ZIG_GLOBAL_CACHE_DIR/p"
            '';

            nativeBuildInputs = [zig.hook];
          };
      };
    };
}

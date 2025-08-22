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

          deps = fetchZigDeps {
            name = "example";
            inherit stdenv zig;
            src = ./.;
            depsHash = "sha256-jbCbmKTdRh3RrK0eyfMeWUqwK6Vsx8Wq65bUSecoZyY=";
          };
        in
          stdenv.mkDerivation {
            pname = "example";
            version = "0.0.1";
            src = ./.;

            postPatch = ''
              mkdir -p .cache
              ln -s ${deps} .cache/p

              ls .cache/p
            '';

            nativeBuildInputs = [zig];

            dontConfigure = true;
            dontInstall = true;

            buildPhase = ''
              mkdir -p $out
              zig build install \
                --cache-dir $(pwd)/zig-cache \
                --global-cache-dir $(pwd)/.cache \
                -Dcpu=baseline \
                -Doptimize=ReleaseSafe \
                --prefix $out
            '';
          };
      };
    };
}

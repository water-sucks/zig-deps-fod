<h1 align="center">zig-deps-fod</h1>
<h6 align="center">Fetch Zig deps into Nix derivations</h6>

## Synopsis

Straight to the point. This fetches Zig dependencies from your `build.zig.zon`
into a derivation that can be symlinked inside your Zig derivations.

That way, you won't need to generate a file using
[`zon2nix`](https://github.com/nix-community/zon2nix) anymore! Because `-2nix`
fetchers kinda suck for DX.

## Usage

This requires Zig version >= 0.12.0.

A single function, `fetchZigDeps` is exposed from this flake. Use it like this
(replacing your invocations of `pkgs` with however you import it):

```nix
{pkgs ? import <nixpkgs> {}}:

let
  name = "example";
  inherit (pkgs) zig stdenv;

  deps = fetchZigDeps {
    inherit name zig stdenv;
    src = ./.;
    depsHash = "sha256-00000000000000000000000000000000000000000000";
  }

in stdenv.mkDerivation {
  pname = "example";
  version = "0.0.1";
  src = ./.;

  postPatch = ''
    ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
    export ZIG_GLOBAL_CACHE_DIR

    ln -s ${deps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  nativeBuildInputs = [zig.hook];

  # ...other attrs for building your zig packages
}
```

An example project using this flake is in the [example](./example) directory.

## Disclaimers

This should only be a temporary measure, for now. I would like to get this into
`nixpkgs` at some point once this is in good shape and is tested with multiple
packages that use Zig in production. I would appreciate testing, and please
report issues or possible improvements. They are greatly appreciated.

<h1 align="center">zig-deps-fod</h1>
<h6 align="center">Fetch Zig deps into Nix derivations</h6>

## Synopsis

Straight to the point. This fetches Zig dependencies from your `build.zig.zon`
into a derivation that can be symlinked inside your Zig derivations.

That way, you won't need to generate a file using
[`zon2nix`](https://github.com/nix-community/zon2nix) anymore! Because `-2nix`
fetchers kinda suck for DX.

This project will be obsolete when/if this
[pull request](https://github.com/NixOS/nixpkgs/pull/438523) to `nixpkgs` is
merged.

## Usage

This requires Zig version >= 0.12.0.

A single function, `fetchZigDeps` is exposed from this flake. Use it like this
(replacing your invocations of `pkgs` with however you import it):

```nix
{pkgs ? import <nixpkgs> {}}:

let
  pname = "example";
  version = "0.0.1";
  src = ./.;

  inherit (pkgs) zig stdenv;

  deps = fetchZigDeps {
    inherit pname version src zig stdenv;
    depsHash = "sha256-00000000000000000000000000000000000000000000";
    # Set this to true if having problems with fetching lazy dependencies
    # in Zig versions prior to 0.15.1.
    # This can resolve some (but not all) issues, and may require upstream
    # to update to Zig 0.15.1 in order to properly vendor dependencies.
    manuallyFetchLazyDeps = false;
  }

in stdenv.mkDerivation {
  inherit pname version src;

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

lib: {
  pname,
  version,
  name ? "${pname}-${version}",
  src,
  zig,
  stdenv,
  hash ? lib.fakeHash,
  manuallyFetchLazyDeps ? false,
} @ args: let
  fetchCommand =
    if lib.versionAtLeast zig.version "0.15"
    then ''
      TERM=dumb zig build --fetch=all
    ''
    else if !manuallyFetchLazyDeps
    then ''
      TERM=dumb zig build --fetch
    ''
    else ''
      fetchDepsForPackage .
    '';
in
  stdenv.mkDerivation ({
      name = "${name}-deps";

      nativeBuildInputs = [zig];

      inherit src;

      dontConfigure = true;

      buildPhase = ''
        runHook preBuild

        export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)

        package_dirs_checked=()

        function fetchDepsForPackage() {
          package="$1"

          if [[ "''${package_dirs_checked[*]}" =~ $package ]]; then
            return 0
          fi
          package_dirs_checked+=("$package")

          if [ -e "$package/build.zig.zon" ]; then
            sed -i '/^\s*\.lazy\s*=\s*true\s*,\s*$/d' "$package/build.zig.zon"

            cd "$package" || exit 1
            TERM=dumb zig build --fetch --global-cache-dir "$zig_cache" --cache-dir "$zig_cache"
            for dir in "$zig_cache"/p/*; do
              fetchDepsForPackage "$dir"
            done
          fi
        }

        ${fetchCommand}

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mv $ZIG_GLOBAL_CACHE_DIR/p $out
        runHook postInstall
      '';

      dontFixup = true;
      dontPatchShebangs = true;

      outputHashAlgo = null;
      outputHashMode = "recursive";
      outputHash = hash;
    }
    // args)

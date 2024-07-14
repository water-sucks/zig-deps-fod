{
  name,
  src,
  packageRoot ? "./",
  zig,
  stdenv,
  depsHash,
}:
stdenv.mkDerivation {
  name = "${name}-deps";

  nativeBuildInputs = [zig];

  inherit src;

  configurePhase = ''
    runHook preConfigure
    cd "${packageRoot}"
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    root_dir=$PWD
    zig_cache="$PWD/.zig-cache"

    package_dirs_checked=()

    function fetchDepsForPackage() {
      package="$1"

      if [[ "''${package_dirs_checked[*]}" =~ $package ]]; then
        return 0
      fi
      package_dirs_checked+=("$package")

      if [ -e "$package/build.zig.zon" ]; then
        cd "$package" || exit 1
        zig build --fetch --global-cache-dir "$zig_cache" --cache-dir "$zig_cache"
        for dir in "$zig_cache"/p/*; do
          fetchDepsForPackage "$dir"
        done
      fi
    }

    fetchDepsForPackage .

    cd $root_dir

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r --reflink=auto "${packageRoot}/.zig-cache/p" $out
    runHook postInstall
  '';

  dontFixup = true;
  dontPatchShebangs = true;

  outputHashMode = "recursive";
  outputHash = depsHash;
}

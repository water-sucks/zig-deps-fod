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
    zig build --fetch --global-cache-dir ".zig-cache" --cache-dir ".zig-cache"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r --reflink=auto .zig-cache/p $out
    runHook postInstall
  '';

  dontFixup = true;
  dontPatchShebangs = true;

  outputHashMode = "recursive";
  outputHash = depsHash;
}

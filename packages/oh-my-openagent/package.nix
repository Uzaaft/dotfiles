{
  lib,
  stdenv,
  bun2nix,
  bun,
  fetchFromGitHub,
  makeWrapper,
  autoPatchelfHook,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hash;
in
stdenv.mkDerivation {
  pname = "oh-my-opencode";
  inherit version;

  src = fetchFromGitHub {
    owner = "code-yeongyu";
    repo = "oh-my-openagent";
    tag = "v${version}";
    inherit hash;
  };

  nativeBuildInputs = [
    bun2nix.hook
    bun
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  dontRunLifecycleScripts = true;
  dontUseBunBuild = true;
  dontUseBunInstall = true;

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
    "libc.musl-aarch64.so.1"
  ];

  buildPhase = ''
    runHook preBuild

    bun build src/index.ts --outdir dist --target bun --format esm --external @ast-grep/napi
    bun build src/cli/index.ts --outdir dist/cli --target bun --format esm --external @ast-grep/napi

    bun run build:schema || true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/oh-my-opencode $out/bin

    cp -r dist node_modules package.json $out/lib/oh-my-opencode/

    makeWrapper ${bun}/bin/bun $out/bin/oh-my-opencode \
      --add-flags "run $out/lib/oh-my-opencode/dist/cli/index.js"

    runHook postInstall
  '';

  passthru.category = "AI Coding Agents";

  meta = with lib; {
    description = "The Best AI Agent Harness - Multi-Model Orchestration for OpenCode";
    homepage = "https://github.com/code-yeongyu/oh-my-openagent";
    changelog = "https://github.com/code-yeongyu/oh-my-openagent/releases/tag/v${version}";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ fromSource ];
    mainProgram = "oh-my-opencode";
    platforms = platforms.unix;
  };
}
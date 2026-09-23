{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  bubblewrap,
  makeWrapper,
  procps,
  ripgrep,
  socat,
  zstd,
}: let
  version = "2.1.280";
  release = {
    "aarch64-darwin" = {
      platform = "darwin-arm64";
      hash = "sha256-IU+v2dYLwDl8todHt2WrdSvktTMDwXatiFxMr74wgm8=";
    };
    "aarch64-linux" = {
      platform = "linux-arm64";
      hash = "sha256-agHzBBjzUSKmcsz3S+1kq6URmtR8cVSKO0R8yf7EjIE=";
    };
    "x86_64-linux" = {
      platform = "linux-x64";
      hash = "sha256-J5EOKucE2PLoAkiX2P3x53EIB7r09pgsDjeXwFgxU4Q=";
    };
  }.${stdenv.hostPlatform.system} or (throw "claude-code: unsupported system ${stdenv.hostPlatform.system}");
in
  stdenv.mkDerivation {
    pname = "claude-code";
    inherit version;

    src = fetchurl {
      url = "https://downloads.claude.ai/claude-code-releases/${version}/${release.platform}/claude.zst";
      inherit (release) hash;
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    # Stripping invokes the bundled Bun runtime rather than the CLI binary.
    dontStrip = true;

    nativeBuildInputs = [
      makeWrapper
      zstd
    ] ++ lib.optionals stdenv.hostPlatform.isElf [autoPatchelfHook];

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [alsa-lib];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      unzstd -q $src -o $out/bin/claude
      chmod 755 $out/bin/claude
      runHook postInstall
    '';

    postFixup = ''
      wrap_args=(
        --prefix PATH : ${lib.makeBinPath ([procps ripgrep] ++ lib.optionals stdenv.hostPlatform.isLinux [bubblewrap socat])}
        --set DISABLE_AUTOUPDATER 1
        --set-default FORCE_AUTOUPDATE_PLUGINS 1
        --set DISABLE_INSTALLATION_CHECKS 1
        --set USE_BUILTIN_RIPGREP 0
      )
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        wrap_args+=(--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [alsa-lib]})
      ''}
      wrapProgram $out/bin/claude "''${wrap_args[@]}"
    '';

    passthru = {
      updateScript = ./update.sh;
    };

    meta = with lib; {
      description = "Agentic coding tool that lives in your terminal";
      homepage = "https://github.com/anthropics/claude-code";
      license = licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      maintainers = with maintainers; [];
      platforms = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      mainProgram = "claude";
    };
  }

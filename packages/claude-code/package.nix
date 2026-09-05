{
  lib,
  stdenv,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  runCommand,
  runtimeShell,
  alsa-lib,
  autoPatchelfHook,
  bubblewrap,
  procps,
  ripgrep,
  socat,
}: let
  version = "2.1.261";

  srcWithLock = runCommand "claude-code-src-with-lock" {} ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-2.1.261.tgz";
        hash = "sha256-zmRL2VAr+LDkIUTSaMVjtSw9pCK9lsA7RDF4QU0/0XI=";
      }
    } -C $out --strip-components=1
    sed -i 's/"postinstall": "node install.cjs",/"postinstall": "node install.cjs"/' $out/package.json
    sed -i '/"prepare":/d' $out/package.json
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
  buildNpmPackage rec {
    pname = "claude-code";
    inherit version;

    src = srcWithLock;

    npmDeps = fetchNpmDeps {
      inherit src;
      hash = "sha256-k6u4MXJT9hsof4duISx2ZE7Gaqzw2ZhyvFyFrqMdF9Q=";
    };

    dontNpmBuild = true;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isElf [autoPatchelfHook];

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [alsa-lib];

    postInstall = ''
      cat > $out/bin/claude <<EOF
      #!${runtimeShell}
      exec $out/lib/node_modules/@anthropic-ai/claude-code/bin/claude.exe "\$@"
      EOF
      chmod +x $out/bin/claude

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

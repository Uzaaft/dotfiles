{
  lib,
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  bubblewrap,
  ripgrep,
}: let
  version = "0.166.0";

  release =
    {
      "aarch64-darwin" = {
        target = "aarch64-apple-darwin";
        hash = "sha256-xIgkRi/FdoHq+wkl2XsRtYkBBHVhOQT1cLQv6lPiQNU=";
        hostHash = "sha256-er1Q/l8DNJWntpPEX7gtxXCToY8cS6PoBDV33kbFx8U=";
      };
      "aarch64-linux" = {
        target = "aarch64-unknown-linux-musl";
        hash = "sha256-lOtwdgXsJkay4Ft+33xOezzPArFiN8NK6b64z7f4EKk=";
        hostHash = "sha256-rJjR+HjjU6FsunEf1Hv+8vbIFBCb3YGe4ra21qGXAec=";
      };
      "x86_64-linux" = {
        target = "x86_64-unknown-linux-musl";
        hash = "sha256-oL9XLS+T8FbGcSpto0jpYHjchPOIX9e+Z4B+84nLOXg=";
        hostHash = "sha256-dYgzT9R7xAA9lwtw39TR5FeEkbHpuqcpdqTC1+l1kNo=";
      };
    }.${
      stdenvNoCC.hostPlatform.system
    }
    or (throw "codex: unsupported system ${stdenvNoCC.hostPlatform.system}");

  # Shipped as a separate release asset. codex resolves it as a sibling of its
  # own argv[0] directory, so it has to land next to $out/bin/codex or Code Mode
  # fails with "codex-code-mode-host is missing".
  codeModeHost = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-code-mode-host-${release.target}.tar.gz";
    hash = release.hostHash;
  };
in
  stdenvNoCC.mkDerivation {
    pname = "codex";
    inherit version;

    src = fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${release.target}.tar.gz";
      inherit (release) hash;
    };

    nativeBuildInputs = [makeBinaryWrapper];

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 codex-${release.target} $out/bin/codex
      tar -xzf ${codeModeHost}
      install -Dm755 codex-code-mode-host-${release.target} $out/bin/codex-code-mode-host
      runHook postInstall
    '';

    # codex resolves bwrap and rg from PATH. Without this they are only visible
    # when the user profile happens to be on PATH, which is not the case for
    # systemd units, IDE extensions, or anything spawning the app-server with a
    # minimal environment.
    postFixup = ''
      wrapProgram $out/bin/codex --prefix PATH : ${lib.makeBinPath (
        [ripgrep] ++ lib.optional stdenvNoCC.hostPlatform.isLinux bubblewrap
      )}
    '';

    passthru.updateScript = ./update.sh;

    meta = with lib; {
      description = "Lightweight coding agent that runs in your terminal";
      homepage = "https://github.com/openai/codex";
      changelog = "https://github.com/openai/codex/releases/tag/rust-v${version}";
      license = licenses.asl20;
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      maintainers = [];
      platforms = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      mainProgram = "codex";
    };
  }

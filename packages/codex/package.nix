{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  fetchzip,
  installShellFiles,
  makeWrapper,
  rustPlatform,
  pkg-config,
  openssl,
  bubblewrap,
  libcap,
  versionCheckHook,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}: let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hash cargoHash;

  # Fetch prebuilt V8 for Deno as a fixed-output derivation so the build stays sandboxed.
  librusty_v8 = fetchurl {
    name = "librusty_v8-${versionData.librusty_v8.version}";
    url = "https://github.com/denoland/rusty_v8/releases/download/v${versionData.librusty_v8.version}/librusty_v8_release_${stdenv.hostPlatform.rust.rustcTarget}.a.gz";
    hash = versionData.librusty_v8.hashes.${stdenv.hostPlatform.system};
    meta.sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };

  # Codex downloads LiveKit WebRTC on macOS during build, so pin it here instead.
  livekitWebrtcTriple =
    {
      x86_64-darwin = "mac-x64";
      aarch64-darwin = "mac-arm64";
    }
    .${
      stdenv.hostPlatform.system
    }
    or null;

  livekitWebrtc =
    if livekitWebrtcTriple == null
    then null
    else
      fetchzip {
        name = "livekit-webrtc-${versionData.livekit_webrtc.tag}-${livekitWebrtcTriple}";
        url = "https://github.com/livekit/rust-sdks/releases/download/${versionData.livekit_webrtc.tag}/webrtc-${livekitWebrtcTriple}-release.zip";
        hash = versionData.livekit_webrtc.hashes.${stdenv.hostPlatform.system};
        meta.sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      };

  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    inherit hash;
  };
in
  rustPlatform.buildRustPackage {
    pname = "codex";
    inherit version src;

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      sourceRoot = "source/codex-rs";
      hash = cargoHash;
    };

    sourceRoot = "source/codex-rs";

    cargoBuildFlags = [
      "--package"
      "codex-cli"
    ];

    nativeBuildInputs = [
      installShellFiles
      makeWrapper
      pkg-config
    ];

    buildInputs = [openssl] ++ lib.optionals stdenv.hostPlatform.isLinux [libcap];

    env =
      {
        RUSTY_V8_ARCHIVE = librusty_v8;
      }
      // lib.optionalAttrs (livekitWebrtc != null) {
        LK_CUSTOM_WEBRTC = livekitWebrtc;
      };

    preBuild = ''
      substituteInPlace Cargo.toml \
        --replace-fail 'lto = "fat"' 'lto = false'
    '';

    postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram $out/bin/codex \
        --prefix PATH : ${lib.makeBinPath [bubblewrap]}
    '';

    doCheck = false;

    postInstall = lib.optionalString installShellCompletions ''
      installShellCompletion --cmd codex \
        --bash <($out/bin/codex completion bash) \
        --fish <($out/bin/codex completion fish) \
        --zsh <($out/bin/codex completion zsh)
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [versionCheckHook];

    passthru.category = "AI Coding Agents";

    meta = with lib; {
      description = "OpenAI Codex CLI - a coding agent that runs locally on your computer";
      homepage = "https://github.com/openai/codex";
      changelog = "https://github.com/openai/codex/releases/tag/rust-v${version}";
      sourceProvenance = with sourceTypes; [
        fromSource
        binaryNativeCode
      ];
      license = licenses.asl20;
      mainProgram = "codex";
      platforms = platforms.unix;
    };
  }

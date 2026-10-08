{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
}: let
  version = "1.18.35";

  platformSources = {
    x86_64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      hash = "sha256-yPiItFH1SUoY+Fj/+w4LaPTkuqnCQXYcXyBohPD6ZA0=";
    };
    aarch64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-arm64.tar.gz";
      hash = "sha256-9/K6We6KqU04j5aWV1oy0g5xwu5I3vn4D8aTpg/sbHI=";
    };
    aarch64-darwin = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
      hash = "sha256-gLBRJDV6d81XlFv942CCoCjoKcGY0iLV4UZhf0mixLc=";
    };
  };
  platformSource = platformSources.${stdenvNoCC.hostPlatform.system}
    or (throw "OpenCode is unsupported on ${stdenvNoCC.hostPlatform.system}");
in
  stdenvNoCC.mkDerivation {
    pname = "opencode";
    inherit version;

    src = fetchurl platformSource;
    sourceRoot = ".";
    nativeBuildInputs = [unzip];
    dontFixup = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 opencode $out/bin/opencode
      runHook postInstall
    '';

    meta = with lib; {
      description = "AI coding agent built for the terminal";
      homepage = "https://opencode.ai/";
      changelog = "https://github.com/anomalyco/opencode/releases";
      license = licenses.mit;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      mainProgram = "opencode";
      platforms = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    };
  }

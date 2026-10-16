{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
}: let
  version = "1.19.0";

  platformSources = {
    x86_64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      hash = "sha256-e7nmGtb+rPLonBCmosGEDj3kIgu1C6H8cRDzGAYHauw=";
    };
    aarch64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-arm64.tar.gz";
      hash = "sha256-6YQdQ9PhqPNu0mkVktO4tPsJfmBsi1WaJ3obhFhA4ms=";
    };
    aarch64-darwin = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
      hash = "sha256-DV9RGUjW+/7fm7FnU8CsQmE9zI3nXZ3rfo0M9YTI+6Y=";
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

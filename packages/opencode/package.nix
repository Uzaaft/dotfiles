{
  fetchurl,
  lib,
  stdenvNoCC,
  unzip,
}: let
  version = "1.19.3";

  platformSources = {
    x86_64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-x64.tar.gz";
      hash = "sha256-E6j7KXgwIHG4b51+ANqciJX5zYRpeDecO9xqUzNTbJs=";
    };
    aarch64-linux = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-linux-arm64.tar.gz";
      hash = "sha256-eQCBimqYiB7butq0t1JZQO/zuXUAQMIASB+fVsrO5AU=";
    };
    aarch64-darwin = {
      url = "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-darwin-arm64.zip";
      hash = "sha256-wtD+zSes9uCL4CwfXThGFNB0lVh3ZrzEpr/zlxdJu2Q=";
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

{
  lib,
  fetchurl,
  ripgrep,
  makeWrapper,
  stdenvNoCC,
}: let
  version = "0.0.1791460855-g1f688c";

  platformSources = {
    x86_64-linux = {
      url = "https://registry.npmjs.org/@ampcode/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
      hash = "sha256-3p7POvm9iJgtcey9tmtw42/uuZfJuY0mnCFjOzOZvrk=";
    };
    aarch64-linux = {
      url = "https://registry.npmjs.org/@ampcode/cli-linux-arm64/-/cli-linux-arm64-${version}.tgz";
      hash = "sha256-16WbjlfqWmK7Gwf92wzGZNWLm1EvDkknKJaKFIkPjBc=";
    };
    x86_64-darwin = {
      url = "https://registry.npmjs.org/@ampcode/cli-darwin-x64/-/cli-darwin-x64-${version}.tgz";
      hash = "sha256-uXeoqe+X5ihfgd6gIz+vkuXGnaMnPW1IOOsm8RToQjE=";
    };
    aarch64-darwin = {
      url = "https://registry.npmjs.org/@ampcode/cli-darwin-arm64/-/cli-darwin-arm64-${version}.tgz";
      hash = "sha256-sCZ3IjrB7yDpCcC1y+NmGAlHlOTfdS1sFmXbOF8yN3U=";
    };
  };
  platformSource = platformSources.${stdenvNoCC.hostPlatform.system}
    or (throw "Amp CLI is unsupported on ${stdenvNoCC.hostPlatform.system}");
in
  stdenvNoCC.mkDerivation {
    pname = "amp";
    inherit version;

    src = fetchurl platformSource;
    sourceRoot = ".";
    nativeBuildInputs = [makeWrapper];

    unpackPhase = ''
      tar -xzf "$src" --strip-components=1
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 amp $out/libexec/amp
      makeWrapper $out/libexec/amp $out/bin/amp \
        --prefix PATH : ${lib.makeBinPath [ripgrep]} \
        --set AMP_SKIP_UPDATE_CHECK 1
      runHook postInstall
    '';

    passthru = {
      updateScript = ./update.sh;
    };

    meta = with lib; {
      description = "CLI for Amp, the frontier coding agent";
      homepage = "https://ampcode.com/";
      changelog = "https://github.com/sourcegraph/amp/releases";
      license = licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [binaryBytecode];
      maintainers = with maintainers; [];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "amp";
    };
  }

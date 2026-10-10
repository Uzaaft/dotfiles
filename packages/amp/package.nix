{
  lib,
  fetchurl,
  ripgrep,
  makeWrapper,
  stdenvNoCC,
}: let
  version = "0.0.1791619249-g722a12";

  platformSources = {
    x86_64-linux = {
      url = "https://registry.npmjs.org/@ampcode/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
      hash = "sha256-ORCaYkte2qbM/97Hxop49GqDl28tu1SZ44bkXgckJ2k=";
    };
    aarch64-linux = {
      url = "https://registry.npmjs.org/@ampcode/cli-linux-arm64/-/cli-linux-arm64-${version}.tgz";
      hash = "sha256-9SVRcAZ3Ur2eA9cV7+3tOR4yCl2GEAckWRdCnRbVjNs=";
    };
    x86_64-darwin = {
      url = "https://registry.npmjs.org/@ampcode/cli-darwin-x64/-/cli-darwin-x64-${version}.tgz";
      hash = "sha256-eCtAFHnkRPetNrko+hltwsst4z6KJi6z7nFxgTHClf0=";
    };
    aarch64-darwin = {
      url = "https://registry.npmjs.org/@ampcode/cli-darwin-arm64/-/cli-darwin-arm64-${version}.tgz";
      hash = "sha256-v40GgGevkvT4HvpgbNGl/awN1Hsv0kO+r2S1ukgGqqM=";
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

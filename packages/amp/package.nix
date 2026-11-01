{
  lib,
  fetchurl,
  ripgrep,
  makeWrapper,
  stdenvNoCC,
}: let
  version = "0.0.1793534443-ga508b6";

  platformSources = {
    x86_64-linux = {
      url = "https://registry.npmjs.org/@ampcode/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
      hash = "sha256-shMwZFBLBkfCJqT/x7lNffp8xFMNsERubf9aNhDBdPc=";
    };
    aarch64-linux = {
      url = "https://registry.npmjs.org/@ampcode/cli-linux-arm64/-/cli-linux-arm64-${version}.tgz";
      hash = "sha256-Trkj6d2S5jRRuQjdDXqxdIA7yazRXFBUJcrFz83PvJ0=";
    };
    x86_64-darwin = {
      url = "https://registry.npmjs.org/@ampcode/cli-darwin-x64/-/cli-darwin-x64-${version}.tgz";
      hash = "sha256-MqnYw9ACVQFc2sijCSm6Yf8S/ZB0WdvBwbCu9Ggiylg=";
    };
    aarch64-darwin = {
      url = "https://registry.npmjs.org/@ampcode/cli-darwin-arm64/-/cli-darwin-arm64-${version}.tgz";
      hash = "sha256-kbf/t2CSbdnODm1Rtf7K74QhYdm5Wa3XxWYRhZT8+0A=";
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

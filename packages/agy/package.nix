{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  ripgrep,
}: let
  version = "1.5.15";
  # URLs embed an upstream build number, so each system pins the full URL.
  release =
    {
      "aarch64-darwin" = {
        url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.15-5514532022517760/darwin-arm/cli_mac_arm64.tar.gz";
        hash = "sha512-sDqEHrOim+kYpmlgt3X2jtTzvMAvM5YhMbu8JsRuqYPOrGyDKtRu/RHXPZosuX30qyTUvJLuR9PV7Oe42LYSNQ==";
      };
      "aarch64-linux" = {
        url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.15-5514532022517760/linux-arm/cli_linux_arm64.tar.gz";
        hash = "sha512-1krXWXgbUN+s+n2YJsCtRplZ0BvfWhcKzUyDRy66McZ3uvAFKsirSO70Dw0/DiYFfnUqq9JDMcefTIgdS4chJQ==";
      };
      "x86_64-linux" = {
        url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.15-5514532022517760/linux-x64/cli_linux_x64.tar.gz";
        hash = "sha512-rz8L5YuEdZQNefmr6hnnYuzD0mXqn1bP+N2AXie6KZtEowWnlQSn/+br36KaKUxW7cTK7Rh1mQv68v7xUI7IsA==";
      };
    }.${stdenv.hostPlatform.system}
    or (throw "agy: unsupported system ${stdenv.hostPlatform.system}");
in
  stdenv.mkDerivation {
    pname = "agy";
    inherit version;

    src = fetchurl {
      inherit (release) url hash;
    };

    sourceRoot = ".";
    dontConfigure = true;
    dontBuild = true;
    # The upstream tarball holds one binary named antigravity; install it as agy.
    installPhase = ''
      runHook preInstall
      install -Dm755 antigravity $out/bin/agy
      runHook postInstall
    '';

    nativeBuildInputs =
      [makeWrapper]
      ++ lib.optionals stdenv.hostPlatform.isElf [autoPatchelfHook];

    postFixup = ''
      wrapProgram $out/bin/agy \
        --prefix PATH : ${lib.makeBinPath [ripgrep]} \
        --set ANTIGRAVITY_DISABLE_EMBEDDED_RIPGREP true \
        --set AGY_CLI_DISABLE_AUTO_UPDATE true
    '';

    passthru = {
      updateScript = ./update.sh;
    };

    meta = with lib; {
      description = "Antigravity coding agent command line tool";
      homepage = "https://antigravity.google";
      license = licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      maintainers = with maintainers; [];
      platforms = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      mainProgram = "agy";
    };
  }

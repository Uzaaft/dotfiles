{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  ripgrep,
}: let
  version = "0.0.1790082161-g365795";
  release = {
    "aarch64-darwin" = {
      platform = "darwin-arm64";
      hash = "sha512-Ad5+MnYUoYEPDD81+bi9WUAIh+NYC2Zl2+SQDIZw4BcW+Jaw19xu9/4HYg1qZabTjF4WpUTuKeBjb8TZswcT+g==";
    };
    "x86_64-darwin" = {
      platform = "darwin-x64";
      hash = "sha512-afUmxk3BnPFBAPLnMPKEiSGbTOOrX1K0dl+lClmA1nhxU/Vu5FYkmAGhy7TM8FzYy0ePSyQ0Fgmjsbhr/+XNWw==";
    };
    "aarch64-linux" = {
      platform = "linux-arm64";
      hash = "sha512-LvSuwFbt82VUV+x6mJsMw2DfJzntN0ryzXt53XkZkeoou0PUk9QFYtoj3uVQDsuOILR34da8k2Iq7NsvpSHIvQ==";
    };
    "x86_64-linux" = {
      platform = "linux-x64";
      hash = "sha512-T2kki685kIL+DdDyPKor3cJF2Du8hxWctxWcoovkLdYCBNRzRjfwSZndIzpw+vTLLhr7PWhDYfbS5LRTXbDwsw==";
    };
  }.${stdenv.hostPlatform.system} or (throw "amp: unsupported system ${stdenv.hostPlatform.system}");
in
  stdenv.mkDerivation {
    pname = "amp";
    inherit version;

    src = fetchurl {
      url = "https://registry.npmjs.org/@ampcode/cli-${release.platform}/-/cli-${release.platform}-${version}.tgz";
      inherit (release) hash;
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      tar -xOf $src package/amp > $out/bin/amp
      chmod 755 $out/bin/amp
      runHook postInstall
    '';

    postFixup = ''
      wrapProgram $out/bin/amp \
        --prefix PATH : ${lib.makeBinPath [ripgrep]} \
        --set AMP_SKIP_UPDATE_CHECK 1
    '';

    passthru = {
      updateScript = ./update.sh;
    };

    meta = with lib; {
      description = "CLI for Amp, the frontier coding agent";
      homepage = "https://ampcode.com/";
      changelog = "https://github.com/sourcegraph/amp/releases";
      license = licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      maintainers = with maintainers; [];
      platforms = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      mainProgram = "amp";
    };
  }

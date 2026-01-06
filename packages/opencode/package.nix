{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  unzip,
  autoPatchelfHook,
  fzf,
  ripgrep,
}:
let
  version = "1.1.3";

  platformMap = {
    x86_64-linux = {
      asset = "opencode-linux-x64.tar.gz";
      hash = "sha256-50rIXLC5ra+8l8a+WRJHv+JQlwDESgX92pEXVhV9i4I=";
      isZip = false;
    };
    aarch64-linux = {
      asset = "opencode-linux-arm64.tar.gz";
      hash = "sha256-qg0gUMZPFnbsvR+mGpknBSzY5mFTcnANkw5h3V9LwYY=";
      isZip = false;
    };
    x86_64-darwin = {
      asset = "opencode-darwin-x64.zip";
      hash = "sha256-4iL9XHvYpGXq2aRuEkpndpG1yXBPZ3cRcX3yLEeZYaI=";
      isZip = true;
    };
    aarch64-darwin = {
      asset = "opencode-darwin-arm64.zip";
      hash = "sha256-R7fHXxgRzk7sYpgGChRXBDeWyWPwYUUF/aJjlyFsSwo=";
      isZip = true;
    };
  };

  platform = platformMap.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "opencode";
  inherit version;

  src = fetchurl {
    url = "https://github.com/sst/opencode/releases/download/v${version}/${platform.asset}";
    inherit (platform) hash;
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    makeWrapper
  ] ++ lib.optionals platform.isZip [ unzip ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 opencode $out/bin/opencode
    wrapProgram $out/bin/opencode \
      --prefix PATH : ${lib.makeBinPath [ fzf ripgrep ]}
    runHook postInstall
  '';

  meta = with lib; {
    description = "An AI-powered coding agent that lives in your terminal";
    homepage = "https://opencode.ai/";
    changelog = "https://github.com/sst/opencode/releases";
    license = licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "opencode";
  };
}

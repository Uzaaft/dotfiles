{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  ripgrep,
  runCommand,
}: let
  version = "0.0.1775981571-g834e73";

  srcWithLock = runCommand "amp-src-with-lock" {} ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@sourcegraph/amp/-/amp-0.0.1775981571-g834e73.tgz";
        hash = "sha256-Pi60XlHw86yJjZOE7jM1yMayOYiAgCU304hLT/bmqwY=";
      }
    } -C $out --strip-components=1
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
  buildNpmPackage rec {
    pname = "amp";
    inherit version;

    src = srcWithLock;

    npmDeps = fetchNpmDeps {
      inherit src;
      hash = "sha256-A1hKJiLNFseb1gGb4XuYQ7/kzrVkLE+/oymo3wCrAq0=";
    };

    dontNpmBuild = true;

    postInstall = ''
      wrapProgram $out/bin/amp \
        --prefix PATH : ${lib.makeBinPath [ripgrep]} \
        --set AMP_SKIP_UPDATE_CHECK 1
    '';

    passthru = {
      updateScript = ./update.sh;
    };

    meta = with lib; {
      description = "CLI for Amp, an agentic coding tool in research preview from Sourcegraph";
      homepage = "https://ampcode.com/";
      changelog = "https://github.com/sourcegraph/amp/releases";
      license = licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [binaryBytecode];
      maintainers = with maintainers; [];
      platforms = platforms.all;
      mainProgram = "amp";
    };
  }

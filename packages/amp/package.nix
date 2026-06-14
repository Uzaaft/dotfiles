{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  ripgrep,
  runCommand,
  runtimeShell,
}: let
  version = "0.0.1781424348-g140afa";

  srcWithLock = runCommand "amp-src-with-lock" {} ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@ampcode/cli/-/cli-0.0.1781424348-g140afa.tgz";
        hash = "sha256-XhP53CF51lSz8s4MmSSScqrNY2Y30C+d3VRNMm7InKQ=";
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
      hash = "sha256-ngCNV1XOlX06cP3z1Wh8qdCGiYvx0QC27Sp5+odLunE=";
    };

    dontNpmBuild = true;

    postInstall = ''
      cat > $out/bin/amp <<EOF
      #!${runtimeShell}
      exec $out/lib/node_modules/@ampcode/cli/bin/amp.exe "\$@"
      EOF
      chmod +x $out/bin/amp

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
      sourceProvenance = with lib.sourceTypes; [binaryBytecode];
      maintainers = with maintainers; [];
      platforms = platforms.all;
      mainProgram = "amp";
    };
  }

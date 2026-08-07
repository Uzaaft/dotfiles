{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  ripgrep,
  runCommand,
  runtimeShell,
}: let
  version = "0.0.1786090945-g2d4407";

  srcWithLock = runCommand "amp-src-with-lock" {} ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@ampcode/cli/-/cli-0.0.1786090945-g2d4407.tgz";
        hash = "sha256-qfUw785mHsRE0pFwz/2O3/phS/fstY2CNEAfPEwZqc0=";
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
      hash = "sha256-fNU1Fd6h2hqY8VJH5OgBHE7ZzioeyFFofQt+DcD7bqA=";
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

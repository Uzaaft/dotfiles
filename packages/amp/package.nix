{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  ripgrep,
  runCommand,
  runtimeShell,
}: let
  version = "0.0.1783674082-g314196";

  srcWithLock = runCommand "amp-src-with-lock" {} ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@ampcode/cli/-/cli-0.0.1783674082-g314196.tgz";
        hash = "sha256-ZVxmlbQwpUYbgy9E/AlW4Fd0XL25Ibs39TvbTQ7WsHM=";
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
      hash = "sha256-/ew2yWrXZzV0HWrlf4HTdMB3keDuRjzET9m7mlYii8A=";
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

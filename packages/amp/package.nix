{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  ripgrep,
  runCommand,
}: let
  version = "0.0.1771917023-g11cfec";

  srcWithLock = runCommand "amp-src-with-lock" {} ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@sourcegraph/amp/-/amp-0.0.1771917023-g11cfec.tgz";
        hash = "sha256-6HqaP1d6zFZ8ba5oPMZ0lohwAPoqygDqGtIUPVt6j4k=";
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
      hash = "sha256-fhSXN6PUgOB1+oKvv3f7gnkKXcUrQhgr+0okk1fpWak=";
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

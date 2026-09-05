{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  ripgrep,
  runCommand,
  runtimeShell,
}: let
  version = "0.85.0";

  srcWithLock = runCommand "pi-src-with-lock" {} ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-0.85.0.tgz";
        hash = "sha256-oIlfcKnv2d3ippuc7gTLO3xaq2j11HqtkrY/J6TKE8g=";
      }
    } -C $out --strip-components=1
    rm -f $out/npm-shrinkwrap.json
    cp ${./package-lock.json} $out/package-lock.json
  '';
in
  buildNpmPackage rec {
    pname = "pi";
    inherit version;

    src = srcWithLock;

    npmDeps = fetchNpmDeps {
      inherit src;
      hash = "sha256-lWGYQNHwlKv+D0vvqo/+9ijtm1aCYahSE67rupHLGC0=";
    };

    dontNpmBuild = true;

    postInstall = ''
      cat > $out/bin/pi <<EOF
      #!${runtimeShell}
      exec $out/lib/node_modules/@earendil-works/pi-coding-agent/dist/cli.js "\$@"
      EOF
      chmod +x $out/bin/pi

      wrapProgram $out/bin/pi \
        --prefix PATH : ${lib.makeBinPath [ripgrep]}
    '';

    passthru = {
      updateScript = ./update.sh;
    };

    meta = with lib; {
      description = "Coding agent CLI with read, bash, edit, write tools and session management";
      homepage = "https://github.com/earendil-works/pi";
      license = licenses.mit;
      maintainers = with maintainers; [];
      platforms = platforms.all;
      mainProgram = "pi";
    };
  }

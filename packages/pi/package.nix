{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  ripgrep,
  runCommand,
  runtimeShell,
}: let
  version = "0.84.1";

  srcWithLock = runCommand "pi-src-with-lock" {} ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-0.84.1.tgz";
        hash = "sha256-ppoYWWAX6RlV/Q/Wd75p+rW26gHVsGIHvO407hUivCA=";
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
      hash = "sha256-g/y+CA4AgK5UmaacltW3KeT2YMli3NHOLZkjUqtdGgU=";
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

{
  lib,
  buildNpmPackage,
  fetchurl,
  fetchNpmDeps,
  ripgrep,
  runCommand,
  runtimeShell,
}: let
  version = "0.80.6";

  srcWithLock = runCommand "pi-src-with-lock" {} ''
    mkdir -p $out
    tar -xzf ${
      fetchurl {
        url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
        hash = "sha256-KndjRkCy2G2Q0kCHu2dVns8jZuD7UqQsVe7UFhR9pBE=";
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
      hash = "sha256-Dtqr6EJ/LLyJ2ECYqK08rvSeMeNG0eGqCIIGwnfmp6A=";
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

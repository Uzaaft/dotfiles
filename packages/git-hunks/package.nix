{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  git,
  gawk,
}:
stdenvNoCC.mkDerivation {
  pname = "git-hunks";
  version = "0-unstable-2026-07-03";

  src = fetchFromGitHub {
    owner = "rockorager";
    repo = "git-hunks";
    rev = "482baff749d3267f01a35bc27e08d949391cb3a4";
    hash = "sha256-0jUN9GDSK6AhkYJfQQv77mpa63Rh5jSDVIgNHNaQqyA=";
  };

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 git-hunks $out/bin/git-hunks
    install -Dm644 git-hunks.1 $out/share/man/man1/git-hunks.1
    wrapProgram $out/bin/git-hunks \
      --prefix PATH : ${lib.makeBinPath [git gawk]}
    runHook postInstall
  '';

  meta = with lib; {
    description = "Non-interactive selective hunk staging for git";
    homepage = "https://github.com/rockorager/git-hunks";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
    mainProgram = "git-hunks";
  };
}

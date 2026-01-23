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
  version = "0-unstable-2026-01-23";

  src = fetchFromGitHub {
    owner = "rockorager";
    repo = "git-hunks";
    rev = "810609b492daae31fd974c220d77c76780db4b11";
    hash = "sha256-VRscBmZ0Q/vL4B+8mkmQGV4Ppoj1qPpDz0kPAACjV94=";
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

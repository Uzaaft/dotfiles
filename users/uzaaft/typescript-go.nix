{
  lib,
  pkgs,
  ...
}:
pkgs.buildGoModule rec {
  pname = "typescript-go";
  version = "unstable-2024-12-20";

  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "typescript-go";
    rev = "main";
    hash = "sha256-hNAn3nAYa/VOZ6BlQSlYfKwCXrS3ySvbTDql76KdBBI=";
  };

  vendorHash = lib.fakeHash;

  meta = {
    description = "TypeScript implementation in Go";
    homepage = "https://github.com/microsoft/typescript-go";
    license = lib.licenses.mit;
    mainProgram = "typescript-go";
  };
}

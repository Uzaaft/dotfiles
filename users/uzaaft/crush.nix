{
  lib,
  pkgs,
  ...
}:
pkgs.buildGoModule (finalAttrs: {
  pname = "crush";
  version = "0.4.0";

  src = pkgs.fetchFromGitHub {
    owner = "charmbracelet";
    repo = "crush";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SjrkQFSjJrPNynARE92uKA53hkstIUBSvQbqcYSsnaM=";
  };
  doCheck = false;
  vendorHash = "sha256-aI3MSaQYUOLJxBxwCoVg13HpxK46q6ZITrw1osx5tiE=";

  meta = {
    description = "Glamourous AI coding agent for your favourite terminal";
    homepage = "https://github.com/charmbracelet/crush";
    changelog = "https://github.com/charmbracelet/crush/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.fsl11Mit;
    mainProgram = "crush";
  };
})

#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/package.nix"
registry_url="https://registry.npmjs.org"

latest_version="${1:-$(curl -fsSL "$registry_url/@ampcode%2fcli/latest" | jq -r '.version')}"
current_version=$(grep -Po 'version = "\K[^"]+' "$package_file")
echo "Current version: $current_version"
echo "Latest version: $latest_version"

if [ "$latest_version" = "$current_version" ]; then
  echo "Package is already up to date!"
  exit 0
fi

sed -i "s/version = \"${current_version}\";/version = \"${latest_version}\";/" "$package_file"

for system_platform in "aarch64-darwin:darwin-arm64" "x86_64-darwin:darwin-x64" "aarch64-linux:linux-arm64" "x86_64-linux:linux-x64"; do
  system="${system_platform%%:*}"
  platform="${system_platform#*:}"
  hash=$(curl -fsSL "$registry_url/@ampcode%2fcli-$platform/$latest_version" | jq -r '.dist.integrity')

  if [[ "$hash" == "null" ]]; then
    echo "Missing integrity hash for $platform" >&2
    exit 1
  fi

  sed -i "/\"$system\" = {/,/    };/ s|hash = \"sha512-[^\"]*\";|hash = \"$hash\";|" "$package_file"
done

echo "Building package to verify..."
NIXPKGS_ALLOW_UNFREE=1 nix build --impure "$script_dir/../.."#amp
echo "Amp updated from $current_version to $latest_version"

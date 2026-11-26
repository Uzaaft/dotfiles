#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/package.nix"
base_url="https://downloads.claude.ai/claude-code-releases"

latest_version="${1:-$(curl -fsSL "$base_url/latest")}"
manifest=$(curl -fsSL "$base_url/$latest_version/manifest.zst.json")

current_version=$(grep -Po 'version = "\K[^"]+' "$package_file")
echo "Current version: $current_version"
echo "Latest version: $latest_version"

if [ "$latest_version" = "$current_version" ]; then
  echo "Package is already up to date!"
  exit 0
fi

sed -i "s/version = \"${current_version}\";/version = \"${latest_version}\";/" "$package_file"

for system_platform in "aarch64-darwin:darwin-arm64" "aarch64-linux:linux-arm64" "x86_64-linux:linux-x64"; do
  system="${system_platform%%:*}"
  platform="${system_platform#*:}"
  hash_hex=$(jq -r --arg platform "$platform" '.platforms[$platform].checksum' <<<"$manifest")

  if [[ "$hash_hex" == "null" ]]; then
    echo "Missing checksum for $platform" >&2
    exit 1
  fi

  hash_sri=$(nix hash convert --hash-algo sha256 --to sri "$hash_hex")
  sed -i "/\"$system\" = {/,/    };/ s|hash = \"sha256-[^\"]*\";|hash = \"$hash_sri\";|" "$package_file"
done

echo "Building package to verify..."
NIXPKGS_ALLOW_UNFREE=1 nix build --impure "$script_dir/../.."#claude-code

echo "Update completed successfully!"
echo "claude-code has been updated from $current_version to $latest_version"

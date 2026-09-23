#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/package.nix"
platform_packages=(
  opencode-linux-x64.tar.gz
  opencode-linux-arm64.tar.gz
  opencode-darwin-arm64.zip
)

current_version=$(grep -Po 'version = "\K[^"]+' "$package_file")
latest_version=$(npm view opencode-ai version)

if [ "$latest_version" = "$current_version" ]; then
  echo "OpenCode is already up to date: $current_version"
  exit 0
fi

sed -i "s/version = \"${current_version}\";/version = \"${latest_version}\";/" "$package_file"

for platform_package in "${platform_packages[@]}"; do
  url="https://github.com/anomalyco/opencode/releases/download/v$latest_version/$platform_package"
  hash=$(nix hash to-sri --type sha256 "$(nix-prefetch-url "$url")")
  awk -v platform_package="$platform_package" -v hash="$hash" '
    $0 ~ platform_package { update_hash = 1 }
    update_hash && /hash = / {
      sub(/hash = "sha256-[^"]*"/, "hash = \"" hash "\"")
      update_hash = 0
    }
    { print }
  ' "$package_file" >"$package_file.tmp"
  mv "$package_file.tmp" "$package_file"
done

NIXPKGS_ALLOW_UNFREE=1 nix build --impure "$script_dir/../.."#opencode
echo "Updated OpenCode from $current_version to $latest_version"

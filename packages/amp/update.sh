#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/package.nix"
platform_packages=(
  cli-linux-x64
  cli-linux-arm64
  cli-darwin-x64
  cli-darwin-arm64
)

current_version=$(grep -Po 'version = "\K[^"]+' "$package_file")

latest_version=""
for platform_package in "${platform_packages[@]}"; do
  package_version=$(npm view "@ampcode/$platform_package" version)
  if [ -z "$latest_version" ]; then
    latest_version="$package_version"
  elif [ "$package_version" != "$latest_version" ]; then
    echo "Amp platform packages have inconsistent versions" >&2
    exit 1
  fi
done

if [ "$latest_version" = "$current_version" ]; then
  echo "Amp is already up to date: $current_version"
  exit 0
fi

sed -i "s/version = \"${current_version}\";/version = \"${latest_version}\";/" "$package_file"

for platform_package in "${platform_packages[@]}"; do
  url="https://registry.npmjs.org/@ampcode/$platform_package/-/$platform_package-$latest_version.tgz"
  hash=$(nix hash to-sri --type sha256 "$(nix-prefetch-url "$url")")
  awk -v platform_package="$platform_package" -v hash="$hash" '
    $0 ~ "@ampcode/" platform_package "/-" { update_hash = 1 }
    update_hash && /hash = / {
      sub(/hash = "sha256-[^"]*"/, "hash = \"" hash "\"")
      update_hash = 0
    }
    { print }
  ' "$package_file" >"$package_file.tmp"
  mv "$package_file.tmp" "$package_file"
done

NIXPKGS_ALLOW_UNFREE=1 nix build --impure "$script_dir/../.."#amp
echo "Updated Amp from $current_version to $latest_version"

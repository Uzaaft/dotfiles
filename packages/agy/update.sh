#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/package.nix"
manifest_base="https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests"

latest_version="${1:-$(curl -fsSL "$manifest_base/linux_amd64.json" | jq -r .version)}"

current_version=$(grep -Po 'version = "\K[^"]+' "$package_file")
echo "Current version: $current_version"
echo "Latest version: $latest_version"

if [ "$latest_version" = "$current_version" ]; then
  echo "Package is already up to date!"
  exit 0
fi

for system_platform in "aarch64-darwin:darwin_arm64" "aarch64-linux:linux_arm64" "x86_64-linux:linux_amd64"; do
  system="${system_platform%%:*}"
  platform="${system_platform#*:}"
  manifest=$(curl -fsSL "$manifest_base/$platform.json")
  version=$(jq -r .version <<<"$manifest")
  url=$(jq -r .url <<<"$manifest")
  hash_hex=$(jq -r .sha512 <<<"$manifest")

  if [[ "$version" != "$latest_version" ]]; then
    echo "Version mismatch for $platform: expected $latest_version, got $version" >&2
    exit 1
  fi

  if [[ "$url" == "null" || "$hash_hex" == "null" ]]; then
    echo "Missing url or checksum for $platform" >&2
    exit 1
  fi

  hash_sri=$(nix hash convert --hash-algo sha512 --to sri "$hash_hex")
  sed -i "/\"$system\" = {/,/};/ s|url = \"[^\"]*\";|url = \"$url\";|" "$package_file"
  sed -i "/\"$system\" = {/,/};/ s|hash = \"sha512-[^\"]*\";|hash = \"$hash_sri\";|" "$package_file"
done

sed -i "s/version = \"${current_version}\";/version = \"${latest_version}\";/" "$package_file"

echo "Building package to verify..."
NIXPKGS_ALLOW_UNFREE=1 nix build --impure "$script_dir/../..#agy"

echo "Update completed successfully!"
echo "agy has been updated from $current_version to $latest_version"

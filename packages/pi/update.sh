#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/package.nix"

echo "Fetching latest version..."
latest_version=$(npm view @earendil-works/pi-coding-agent version)
echo "Latest version: $latest_version"

current_version=$(grep -Po 'version = "\K[^"]+' "$package_file")
echo "Current version: $current_version"

if [ "$latest_version" = "$current_version" ]; then
  echo "Package is already up to date!"
  exit 0
fi

echo "Update available: $current_version -> $latest_version"

sed -i "s/version = \"${current_version}\";/version = \"${latest_version}\";/" "$package_file"
sed -i "s|/@earendil-works/pi-coding-agent/-/pi-coding-agent-[^/]\\+\\.tgz|/@earendil-works/pi-coding-agent/-/pi-coding-agent-${latest_version}.tgz|" "$package_file"

echo "Getting new source hash..."
new_hash=$(nix-prefetch-url "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${latest_version}.tgz" | tail -1)
new_sri_hash=$(nix hash to-sri --type sha256 "$new_hash")

awk -v new_hash="$new_sri_hash" '
  /url = "https:\/\/registry\.npmjs\.org\/@earendil-works\/pi-coding-agent/ { found=1 }
  found && /hash = / {
    sub(/hash = "sha256-[^"]*"/, "hash = \"" new_hash "\"")
    found=0
  }
  { print }
' "$package_file" >"$package_file.tmp" && mv "$package_file.tmp" "$package_file"

echo "Generating package-lock.json from new version..."
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

curl -sL "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${latest_version}.tgz" | tar -xz -C "$temp_dir"
cd "$temp_dir/package"
rm -f npm-shrinkwrap.json
npm install --ignore-scripts
cp package-lock.json "$script_dir/package-lock.json"
cd "$script_dir"

echo "Calculating new npmDeps hash..."
awk '
  /npmDeps = fetchNpmDeps/ { in_npmDeps=1 }
  in_npmDeps && /hash = / {
    sub(/hash = "sha256-[^"]*"/, "hash = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\"")
    in_npmDeps=0
  }
  { print }
' "$package_file" >"$package_file.tmp" && mv "$package_file.tmp" "$package_file"

if ! npm_deps_output=$(nix build --impure "$script_dir/../.."#pi 2>&1); then
  correct_npm_hash=$(echo "$npm_deps_output" | grep -E "got:[[:space:]]*sha256-" | awk '{print $2}' | head -1)

  if [ -n "$correct_npm_hash" ]; then
    echo "Updating npmDeps hash to: $correct_npm_hash"
    awk -v new_hash="$correct_npm_hash" '
      /npmDeps = fetchNpmDeps/ { in_npmDeps=1 }
      in_npmDeps && /hash = / {
        sub(/hash = "sha256-[^"]*"/, "hash = \"" new_hash "\"")
        in_npmDeps=0
      }
      { print }
    ' "$package_file" >"$package_file.tmp" && mv "$package_file.tmp" "$package_file"
  else
    echo "Warning: Could not extract npmDeps hash from error output"
    echo "$npm_deps_output" | grep -A2 -B2 "hash mismatch" || echo "$npm_deps_output" | tail -20
  fi
fi

echo "Building package to verify..."
nix build --impure "$script_dir/../.."#pi

echo "Update completed successfully!"
echo "pi has been updated from $current_version to $latest_version"

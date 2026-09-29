#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/package.nix"

echo "Fetching latest revision..."
latest_rev=$(git ls-remote https://github.com/rockorager/git-hunks.git HEAD | awk '{print $1}')
echo "Latest revision: $latest_rev"

current_rev=$(sed -nE 's/^[[:space:]]*rev = "([^"]+)";.*/\1/p' "$package_file")
echo "Current revision: $current_rev"

if [ "$latest_rev" = "$current_rev" ]; then
  echo "Package is already up to date!"
  exit 0
fi

echo "Update available: $current_rev -> $latest_rev"

commit_date=$(curl -s "https://api.github.com/repos/rockorager/git-hunks/commits/${latest_rev}" |
  sed -nE 's/.*"date":[[:space:]]*"([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/p' |
  sed -n '1p')
if [ -z "$commit_date" ]; then
  echo "Warning: Could not fetch commit date, keeping current version date"
else
  sed -E "s/version = \"0-unstable-[0-9-]+\";/version = \"0-unstable-${commit_date}\";/" \
    "$package_file" >"$package_file.tmp"
  mv "$package_file.tmp" "$package_file"
fi

sed "s/rev = \"${current_rev}\";/rev = \"${latest_rev}\";/" \
  "$package_file" >"$package_file.tmp"
mv "$package_file.tmp" "$package_file"

echo "Getting new source hash..."
new_hash=$(nix-prefetch-url --unpack "https://github.com/rockorager/git-hunks/archive/${latest_rev}.tar.gz" | tail -1)
new_sri_hash=$(nix hash to-sri --type sha256 "$new_hash")

sed "s|hash = \"sha256-[^\"]*\";|hash = \"${new_sri_hash}\";|" \
  "$package_file" >"$package_file.tmp"
mv "$package_file.tmp" "$package_file"

echo "Building package to verify..."
nix build --impure "$script_dir/../.."#git-hunks

echo "Update completed successfully!"
echo "git-hunks has been updated from $current_rev to $latest_rev"

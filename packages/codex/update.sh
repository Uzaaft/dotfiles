#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_file="$script_dir/package.nix"
release_api="https://api.github.com/repos/openai/codex/releases/latest"

echo "Fetching latest release..."
release_json=$(curl -fsSL "$release_api")
latest_tag=$(jq -r '.tag_name' <<<"$release_json")
latest_version="${latest_tag#rust-v}"
current_version=$(grep -Po 'version = "\K[^"]+' "$package_file")

if [[ "$latest_tag" != rust-v* || -z "$latest_version" ]]; then
  echo "Unexpected release tag: $latest_tag" >&2
  exit 1
fi

echo "Latest version: $latest_version"
echo "Current version: $current_version"

if [[ "$latest_version" == "$current_version" ]]; then
  echo "Package is already up to date!"
  exit 0
fi

declare -A systems=(
  [aarch64-darwin]=aarch64-apple-darwin
  [aarch64-linux]=aarch64-unknown-linux-musl
  [x86_64-linux]=x86_64-unknown-linux-musl
)

sed -i "s/version = \"$current_version\";/version = \"$latest_version\";/" "$package_file"

digest_for() {
  local asset="$1"
  local digest
  digest=$(jq -r --arg asset "$asset" '.assets[] | select(.name == $asset) | .digest' <<<"$release_json")

  if [[ "$digest" != sha256:* ]]; then
    echo "Missing SHA-256 digest for $asset" >&2
    exit 1
  fi

  nix hash convert --hash-algo sha256 --to sri "${digest#sha256:}"
}

for system in aarch64-darwin aarch64-linux x86_64-linux; do
  target="${systems[$system]}"
  hash=$(digest_for "codex-$target.tar.gz")
  host_hash=$(digest_for "codex-code-mode-host-$target.tar.gz")

  TARGET="$target" HASH="$hash" HOST_HASH="$host_hash" perl -0pi -e '
    $target = quotemeta $ENV{TARGET};
    $hash = $ENV{HASH};
    $host_hash = $ENV{HOST_HASH};
    s/(target = "$target";\n\s+hash = ")[^"]+/$1$hash/;
    s/(target = "$target";\n\s+hash = "[^"]+";\n\s+hostHash = ")[^"]+/$1$host_hash/;
  ' "$package_file"
done

echo "Building package to verify..."
nix build --impure "path:$script_dir/../..#codex"

echo "codex has been updated from $current_version to $latest_version"

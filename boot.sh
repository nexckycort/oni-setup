#!/usr/bin/env bash
set -Eeuo pipefail

for dependency in curl tar; do
  command -v "$dependency" >/dev/null 2>&1 || {
    printf 'Required command not found: %s\n' "$dependency" >&2
    exit 1
  }
done

SETUP_DIR=$(mktemp -d)
trap 'rm -rf -- "$SETUP_DIR"' EXIT

echo 'Downloading Oni Setup...'
curl -fsSL --retry 3 https://github.com/nexckycort/oni-setup/archive/refs/heads/main.tar.gz \
  -o "$SETUP_DIR/oni-setup.tar.gz"
mkdir "$SETUP_DIR/source"
tar -xzf "$SETUP_DIR/oni-setup.tar.gz" -C "$SETUP_DIR/source" --strip-components=1

echo 'Starting installation...'
bash "$SETUP_DIR/source/install.sh" --apply

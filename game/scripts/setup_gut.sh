#!/usr/bin/env bash
# Fetch the GUT test framework into game/addons/gut (not vendored; see .gitignore).
# Usage: GUT_VERSION=v9.3.0 ./scripts/setup_gut.sh
set -euo pipefail

GUT_VERSION="${GUT_VERSION:-v9.3.0}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${HERE}/../addons/gut"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git clone --depth 1 --branch "$GUT_VERSION" https://github.com/bitwes/Gut.git "$tmp"
mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -r "$tmp/addons/gut" "$DEST"

echo "GUT ${GUT_VERSION} installed to ${DEST}"

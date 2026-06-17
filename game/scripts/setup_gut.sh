#!/usr/bin/env bash
# Fetch the GUT test framework into game/addons/gut (not vendored; see .gitignore).
# Usage:
#   ./scripts/setup_gut.sh                 # latest GUT (default branch)
#   GUT_VERSION=v9.3.0 ./scripts/setup_gut.sh   # a specific tag/branch
# Default is the latest because GUT must match the project's Godot version
# (older pinned GUT releases can hang on exit under newer Godot).
set -euo pipefail

GUT_VERSION="${GUT_VERSION:-}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${HERE}/../addons/gut"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

if [ -n "$GUT_VERSION" ]; then
	git clone --depth 1 --branch "$GUT_VERSION" https://github.com/bitwes/Gut.git "$tmp"
else
	git clone --depth 1 https://github.com/bitwes/Gut.git "$tmp"
fi
mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -r "$tmp/addons/gut" "$DEST"

echo "GUT ${GUT_VERSION} installed to ${DEST}"

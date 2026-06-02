#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="BatteryTruth"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
ZIP_FILE="$ROOT_DIR/dist/$APP_NAME-macOS14.zip"

cd "$ROOT_DIR"

"$ROOT_DIR/script/build_and_run.sh" --verify

rm -f "$ZIP_FILE"
ditto -c -k --keepParent --norsrc --noextattr "$APP_BUNDLE" "$ZIP_FILE"

echo "$ZIP_FILE"

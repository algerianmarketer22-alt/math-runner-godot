#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_VERSION=4.6.3
GODOT_DOWNLOAD_BASE="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable"
TOOL_DIRECTORY="${TMPDIR:-/tmp}/math-runner-godot-${GODOT_VERSION}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${TMPDIR:-/tmp}/math-runner-data}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${TMPDIR:-/tmp}/math-runner-cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${TMPDIR:-/tmp}/math-runner-config}"
mkdir -p "$TOOL_DIRECTORY" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME"

verified_download() {
  local asset="$1"
  curl --fail --location --retry 3 --silent --show-error "$GODOT_DOWNLOAD_BASE/$asset" -o "$TOOL_DIRECTORY/$asset"
  curl --fail --location --retry 3 --silent --show-error "$GODOT_DOWNLOAD_BASE/SHA512-SUMS.txt" -o "$TOOL_DIRECTORY/SHA512-SUMS.txt"
  (cd "$TOOL_DIRECTORY" && awk -v asset="$asset" '$2 == asset' SHA512-SUMS.txt | sha512sum --check --strict -)
}

if [[ -n "${GODOT_BIN:-}" ]]; then
  GODOT_EXECUTABLE="$GODOT_BIN"
elif command -v godot >/dev/null 2>&1; then
  GODOT_EXECUTABLE="$(command -v godot)"
elif command -v godot4 >/dev/null 2>&1; then
  GODOT_EXECUTABLE="$(command -v godot4)"
else
  GODOT_EXECUTABLE="$TOOL_DIRECTORY/Godot_v${GODOT_VERSION}-stable_linux.x86_64"
  if [[ ! -x "$GODOT_EXECUTABLE" ]]; then
    asset="Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
    verified_download "$asset"
    unzip -q -o "$TOOL_DIRECTORY/$asset" -d "$TOOL_DIRECTORY"
    chmod +x "$GODOT_EXECUTABLE"
  fi
fi

engine_version="$("$GODOT_EXECUTABLE" --headless --version)"
if [[ "$engine_version" != "${GODOT_VERSION}."* ]]; then
  echo "Godot $GODOT_VERSION requis, version trouvée : $engine_version" >&2
  exit 1
fi

TEMPLATE_DIRECTORY="$XDG_DATA_HOME/godot/export_templates/${GODOT_VERSION}.stable"
if [[ ! -f "$TEMPLATE_DIRECTORY/web_nothreads_release.zip" ]]; then
  asset="Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
  verified_download "$asset"
  mkdir -p "$TEMPLATE_DIRECTORY"
  unzip -q -o -j "$TOOL_DIRECTORY/$asset" 'templates/web_*' 'templates/version.txt' -d "$TEMPLATE_DIRECTORY"
fi

mkdir -p "$PROJECT_ROOT/build/web"
"$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" --export-release Web "$PROJECT_ROOT/build/web/index.html"

#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${GODOT_BIN:-}" ]]; then
  GODOT_EXECUTABLE="$GODOT_BIN"
elif command -v godot >/dev/null 2>&1; then
  GODOT_EXECUTABLE="$(command -v godot)"
else
  GODOT_EXECUTABLE="$(command -v godot4)"
fi

# Cloud sandboxes can have a read-only home directory. Never change HOME.
export XDG_DATA_HOME="${XDG_DATA_HOME:-${TMPDIR:-/tmp}/math-runner-data}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${TMPDIR:-/tmp}/math-runner-cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${TMPDIR:-/tmp}/math-runner-config}"
mkdir -p "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME"

run_godot() {
  local test_log
  test_log="$(mktemp "${TMPDIR:-/tmp}/math-runner-test.XXXXXX")"
  if ! "$GODOT_EXECUTABLE" --headless --path "$PROJECT_ROOT" "$@" >"$test_log" 2>&1; then
    cat "$test_log"
    rm -f "$test_log"
    return 1
  fi
  cat "$test_log"
  # Some GDScript parse/runtime errors do not set a nonzero process exit code.
  if grep -Eq 'SCRIPT ERROR:|ERROR:|WARNING:.*leaked' "$test_log"; then
    rm -f "$test_log"
    return 1
  fi
  rm -f "$test_log"
}

"$GODOT_EXECUTABLE" --headless --version
run_godot --script res://tests/test_rules.gd
run_godot --script res://tests/test_game.gd
run_godot --script res://tests/test_touch.gd
run_godot --fixed-fps 60 --script res://tests/test_level.gd
run_godot --fixed-fps 60 --quit-after 4200

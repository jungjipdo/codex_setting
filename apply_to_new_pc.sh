#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST_DIR="${CODEX_HOME:-$HOME/.codex}"
BACKUP_BASE="$DEST_DIR/backups"
SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<EOF
Usage:
  $SCRIPT_NAME [apply]
  $SCRIPT_NAME restore-latest
  $SCRIPT_NAME restore <backup_timestamp_or_path>
  $SCRIPT_NAME list-backups

Notes:
  - apply (default): backs up current settings and applies files in this folder.
  - restore-latest: restores from newest backup.
  - restore: restores from a specific backup timestamp or full backup path.
  - CODEX_HOME can override target dir (default: ~/.codex).
EOF
}

require_source_files() {
  local missing=0
  for rel in "config.toml" "AGENTS.md" "rules/default.rules"; do
    if [[ ! -f "$SRC_DIR/$rel" ]]; then
      echo "Missing source file: $SRC_DIR/$rel" >&2
      missing=1
    fi
  done
  if [[ "$missing" -eq 1 ]]; then
    exit 1
  fi
}

backup_one() {
  local rel="$1"
  local backup_dir="$2"
  local src="$DEST_DIR/$rel"
  local dst="$backup_dir/$rel"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    printf "%s\t1\n" "$rel" >> "$backup_dir/manifest.tsv"
  else
    printf "%s\t0\n" "$rel" >> "$backup_dir/manifest.tsv"
  fi
}

backup_current_settings() {
  local backup_dir="$1"
  mkdir -p "$backup_dir/rules"
  : > "$backup_dir/manifest.tsv"
  backup_one "config.toml" "$backup_dir"
  backup_one "AGENTS.md" "$backup_dir"
  backup_one "rules/default.rules" "$backup_dir"
}

apply_settings() {
  require_source_files
  mkdir -p "$DEST_DIR/rules"
  mkdir -p "$BACKUP_BASE"

  local ts backup_dir
  ts="$(date +%Y%m%d-%H%M%S)"
  backup_dir="$BACKUP_BASE/$ts"
  backup_current_settings "$backup_dir"

  cp "$SRC_DIR/config.toml" "$DEST_DIR/config.toml"
  cp "$SRC_DIR/AGENTS.md" "$DEST_DIR/AGENTS.md"
  cp "$SRC_DIR/rules/default.rules" "$DEST_DIR/rules/default.rules"

  cat <<EOF
Applied Codex settings to: $DEST_DIR
Backup saved to: $backup_dir

Next steps:
1) Restart Codex app
2) Run: codex features list

Rollback:
- Latest backup: $SCRIPT_NAME restore-latest
- Specific backup: $SCRIPT_NAME restore $(basename "$backup_dir")
EOF
}

resolve_backup_dir() {
  local input="$1"
  if [[ -d "$input" ]]; then
    echo "$input"
    return 0
  fi
  if [[ -d "$BACKUP_BASE/$input" ]]; then
    echo "$BACKUP_BASE/$input"
    return 0
  fi
  echo "Backup not found: $input" >&2
  exit 1
}

restore_from_backup() {
  local backup_dir="$1"
  local manifest="$backup_dir/manifest.tsv"
  if [[ ! -f "$manifest" ]]; then
    echo "Invalid backup (manifest missing): $backup_dir" >&2
    exit 1
  fi

  mkdir -p "$DEST_DIR/rules"

  while IFS=$'\t' read -r rel existed; do
    local src="$backup_dir/$rel"
    local dst="$DEST_DIR/$rel"
    if [[ "$existed" == "1" ]]; then
      if [[ ! -f "$src" ]]; then
        echo "Corrupted backup (missing file): $src" >&2
        exit 1
      fi
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"
    else
      rm -f "$dst"
    fi
  done < "$manifest"

  echo "Restored Codex settings from: $backup_dir"
  echo "Restart Codex app and run: codex features list"
}

restore_latest() {
  local latest
  latest="$(ls -1dt "$BACKUP_BASE"/* 2>/dev/null | head -n 1 || true)"
  if [[ -z "$latest" ]]; then
    echo "No backups found in: $BACKUP_BASE" >&2
    exit 1
  fi
  restore_from_backup "$latest"
}

list_backups() {
  if [[ ! -d "$BACKUP_BASE" ]]; then
    echo "No backups directory yet: $BACKUP_BASE"
    return 0
  fi
  ls -1dt "$BACKUP_BASE"/* 2>/dev/null || true
}

cmd="${1:-apply}"
case "$cmd" in
  apply)
    apply_settings
    ;;
  restore-latest)
    restore_latest
    ;;
  restore)
    if [[ $# -lt 2 ]]; then
      echo "restore requires a backup timestamp or path." >&2
      usage
      exit 1
    fi
    restore_from_backup "$(resolve_backup_dir "$2")"
    ;;
  list-backups)
    list_backups
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage
    exit 1
    ;;
esac

#!/usr/bin/env bash
# ==============================================================================
# Script: backup-rotate.sh
# EN: Creates compressed tar.gz backups, writes SHA-256 checksums, and rotates old archives.
# PT: Cria backups compactados tar.gz, gera hashes SHA-256 e remove arquivos antigos.
# Usage: ./backup-rotate.sh <source_dir> <backup_dest_dir> [retention_days]
# ==============================================================================

set -euo pipefail

SOURCE_DIR="${1:-}"
BACKUP_DIR="${2:-}"
RETENTION_DAYS="${3:-7}"

if [[ -z "$SOURCE_DIR" || -z "$BACKUP_DIR" ]]; then
    echo "Usage: $0 <source_dir> <backup_dest_dir> [retention_days]"
    exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "[ERROR] Source directory does not exist: $SOURCE_DIR" >&2
    exit 1
fi

mkdir -p "$BACKUP_DIR"

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
BASENAME="$(basename "$SOURCE_DIR")"
ARCHIVE_NAME="${BASENAME}_backup_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

echo "[INFO] Starting backup of '${SOURCE_DIR}' -> '${ARCHIVE_PATH}'..."
tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SOURCE_DIR")" "$BASENAME"

sha256sum "$ARCHIVE_PATH" > "${ARCHIVE_PATH}.sha256"
echo "[OK] Backup archive and SHA-256 checksum created successfully."

echo "[INFO] Rotating backups older than ${RETENTION_DAYS} days in '${BACKUP_DIR}'..."
find "$BACKUP_DIR" -maxdepth 1 -type f \( -name "${BASENAME}_backup_*.tar.gz" -o -name "${BASENAME}_backup_*.sha256" \) -mtime +"$RETENTION_DAYS" -print -delete

echo "[OK] Backup rotation completed."

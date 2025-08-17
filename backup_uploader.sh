mkdir -p /home/dhole/gdrive/backups

cat > /home/dhole/backup_uploader.sh <<'SH'
#!/usr/bin/env bash
set -euo pipefail

SRC="/home/dhole/gdrive/upload_data"
DST="/home/dhole/gdrive/backups"
TS="$(date +%Y%m%d-%H%M%S)"
OUT="$DST/uploader_uploads-$TS.tar.gz"

mkdir -p "$DST"
/bin/tar -C "$SRC" -czf "$OUT" .
/usr/bin/sha256sum "$OUT" > "$OUT.sha256"

echo "Backup created: $OUT"
SH

chmod +x /home/dhole/backup_uploader.sh

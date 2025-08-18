#!/bin/bash

# Source directory (your GDrive mounted location)
SRC_DIR="/home/ubuntu/gdrive/upload_data"

# Backup destination directory
BACKUP_DIR="/home/ubuntu/gdrive/backups"

# Create destination directory if not exists
mkdir -p "$BACKUP_DIR"

# Backup filename with timestamp
BACKUP_FILE="$BACKUP_DIR/upload_data_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

# Create tar archive
tar -czf "$BACKUP_FILE" -C "$SRC_DIR" .

# Print confirmation
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"
else
    echo "Backup failed!"
fi
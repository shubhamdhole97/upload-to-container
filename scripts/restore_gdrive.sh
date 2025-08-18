#!/bin/bash

# Backup and restore paths
BACKUP_DIR="/home/ubuntu/gdrive/backups"
RESTORE_DIR="/home/ubuntu/gdrive/upload_data"

# Find the latest backup file
LATEST_BACKUP=$(ls -t $BACKUP_DIR/upload_data_backup_*.tar.gz | head -n 1)

# Check if backup exists
if [ -f "$LATEST_BACKUP" ]; then
    echo "Restoring from: $LATEST_BACKUP"

    # Clean old data (optional, remove if you just want to overwrite files)
    rm -rf "$RESTORE_DIR"/*

    # Extract backup into upload_data
    tar -xzf "$LATEST_BACKUP" -C "$RESTORE_DIR"

    echo "Restore completed at $(date)"
else
    echo "No backup file found!"
fi
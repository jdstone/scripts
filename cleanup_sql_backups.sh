#!/usr/bin/env bash

# Script to delete SQL backup files older than 60 days
# Usage: ./cleanup_sql_backups.sh [directory_path]
# NOTE: Generated via Cursor IDE AI on 9/3/2025

# Set default directory to current directory if none provided
BACKUP_DIR="${1:-.}"

# Check if directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Directory '$BACKUP_DIR' does not exist."
    exit 1
fi

# Check if directory is readable
if [ ! -r "$BACKUP_DIR" ]; then
    echo "Error: Directory '$BACKUP_DIR' is not readable."
    exit 1
fi

echo "Cleaning up SQL backup files older than 60 days in: $BACKUP_DIR"
echo "================================================"

# Counter for deleted files
deleted_count=0
total_size=0

# Find and delete SQL backup files older than 60 days
# This handles common SQL backup file extensions: .sql, .bak, .backup, .dump
while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        # Get file size for reporting
        file_size=$(stat -c%s "$file" 2>/dev/null || echo "0")
        
        echo "Deleting: $file ($(numfmt --to=iec $file_size))"
        
        # Delete the file
        if rm "$file" 2>/dev/null; then
            ((deleted_count++))
            ((total_size += file_size))
        else
            echo "  Warning: Failed to delete $file"
        fi
    fi
done < <(find "$BACKUP_DIR" -type f \( -name "*.sql" -o -name "*.bak" -o -name "*.backup" -o -name "*.dump" \) -mtime +60 -print0 2>/dev/null)

echo "================================================"
echo "Cleanup completed!"
echo "Files deleted: $deleted_count"
echo "Total space freed: $(numfmt --to=iec $total_size)"

# If no files were found/deleted, show a message
if [ $deleted_count -eq 0 ]; then
    echo "No SQL backup files older than 60 days were found."
fi

exit 0


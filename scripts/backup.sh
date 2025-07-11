#!/bin/bash
# scripts/backup.sh

BACKUP_DIR="./backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p $BACKUP_DIR

# Backup of the code
tar -czf $BACKUP_DIR/app-backup.tar.gz *.js *.json public/

# Backup Docker images
docker save my-app-devops:latest > $BACKUP_DIR/docker-image.tar

echo "✅ Backup completed in $BACKUP_DIR"
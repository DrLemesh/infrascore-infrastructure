#!/bin/bash
set -e

# Configuration
NAMESPACE="prod"
DB_POD_LABEL="app.kubernetes.io/name=database-chart"
BACKUP_BUCKET="infrascore-db-backup-prod"
DB_USER="admin"
DB_NAME="quiz_project"

# Ensure AWS CLI and kubectl are installed
if ! command -v aws &> /dev/null; then
    echo "Error: aws cli is not installed."
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed."
    exit 1
fi

echo "Fetching latest backup from S3..."
aws s3 cp s3://$BACKUP_BUCKET/latest_backup.sql ./latest_backup.sql

echo "Finding database pod..."
DB_POD=$(kubectl get pods -n $NAMESPACE -l $DB_POD_LABEL -o jsonpath="{.items[0].metadata.name}")

if [ -z "$DB_POD" ]; then
    echo "Error: Database pod not found in namespace $NAMESPACE"
    exit 1
fi

echo "Restoring database to pod: $DB_POD"
# Use 'cat' to pipe the file content. 
# We ignore errors (OR just specific ones) because re-running restore on existing DB might fail on 'create table' if they exist.
# But for a fresh DB (after destroy/apply), it should be clean.

cat latest_backup.sql | kubectl exec -i $DB_POD -n $NAMESPACE -- psql -U $DB_USER -d $DB_NAME

echo "Restore complete!"

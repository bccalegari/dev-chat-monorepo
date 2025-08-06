#!/bin/bash

ENV_FILE="../.env"

if [ -f "$ENV_FILE" ]; then
  echo "Loading environment variables from $ENV_FILE..."
  set -o allexport
  source "$ENV_FILE"
  set +o allexport
else
  echo "Environment file not found: $ENV_FILE"
  exit 1
fi

TABLE_NAME="public.user_entity"

echo "Setting REPLICA IDENTITY FULL on table $TABLE_NAME..."

PGPASSWORD="$KEYCLOAK_DB_PASSWORD" psql \
  -h  devchat.localhost \
  -p 5432 \
  -U "$KEYCLOAK_DB_USERNAME" \
  -d "$KEYCLOAK_DB_PASSWORD" \
  -c "ALTER TABLE $TABLE_NAME REPLICA IDENTITY FULL;"

if [ $? -eq 0 ]; then
    echo "REPLICA IDENTITY FULL successfully applied."
else
    echo "Failed to apply REPLICA IDENTITY FULL on table $TABLE_NAME." >&2
    exit 1
fi

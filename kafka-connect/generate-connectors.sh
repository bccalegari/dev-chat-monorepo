#!/bin/bash

set -euo pipefail

TEMPLATE_FILE="connectors/keycloak-connector-template.json"
OUTPUT_FILE="connectors/keycloak-connector.json"
ENV_FILE="../.env"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Template file '$TEMPLATE_FILE' not found."
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "Environment file '$ENV_FILE' not found."
  exit 1
fi

export $(grep -v '^#' "$ENV_FILE" | xargs)

envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "'$OUTPUT_FILE' has been successfully generated!"
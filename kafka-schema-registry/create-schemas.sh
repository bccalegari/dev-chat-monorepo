#!/bin/bash

SCHEMA_REGISTRY_URL="kafka-schema-registry.devchat.localhost"
SCHEMAS_DIR="./schemas"

echo "Starting schema registration in Schema Registry..."

until curl -s "$SCHEMA_REGISTRY_URL" > /dev/null; do
  echo "Waiting for Schema Registry at $SCHEMA_REGISTRY_URL..."
  sleep 2
done

for schema_file in "$SCHEMAS_DIR"/*.json; do
  [ -e "$schema_file" ] || continue

  filename=$(basename "$schema_file")

  schema_name=$(jq -r '.name' "$schema_file")
  if [ -z "$schema_name" ] || [ "$schema_name" == "null" ]; then
    echo "Warning: Schema in file '$filename' has no 'name' field. Skipping."
    continue
  fi

  subject="${schema_name}-value"

  schema_str=$(jq -Rs '.' "$schema_file")

  echo "Registering schema for subject '$subject' from file '$filename'..."

  payload="{\"schema\":$schema_str}"

  response=$(curl -s -w "%{http_code}" -X POST \
    -H "Content-Type: application/vnd.schemaregistry.v1+json" \
    --data "$payload" \
    "$SCHEMA_REGISTRY_URL/subjects/$subject/versions")

  http_code="${response: -3}"
  body="${response::-3}"

  if [[ "$http_code" == "200" ]] || [[ "$http_code" == "201" ]]; then
    echo "Schema registered successfully for subject '$subject'. ID: $(echo $body | jq '.id')"
  elif [[ "$http_code" == "409" ]]; then
    echo "Schema for subject '$subject' already exists (409 Conflict). Skipping..."
  else
    echo "Failed to register schema for subject '$subject'. HTTP $http_code. Response: $body"
  fi
done

echo "All schemas in $SCHEMAS_DIR have been processed."
echo "Schema registration completed."
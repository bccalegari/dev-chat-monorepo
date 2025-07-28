#!/bin/bash

CONNECT_URL="http://kafka-connect.devchat.localhost/connectors"
CONNECTORS_DIR="./connectors"

echo "Starting Kafka Connect connectors creation..."

until curl -s "$CONNECT_URL" > /dev/null; do
    echo "Waiting for Kafka Connect at $CONNECT_URL..."
    sleep 2
done

for file in "$CONNECTORS_DIR"/*.json; do
    [ -e "$file" ] || continue

    if [[ "$file" == *"-template.json" ]]; then
        echo "Skipping template file: $file"
        continue
    fi

    filename=$(basename "$file")
    connector_name="${filename%.json}"
    
    if curl -s "$CONNECT_URL/$connector_name" | grep -q '"name"'; then
        echo "Connector '$connector_name' already exists. Skipping..."
    else
        echo "Creating connector '$connector_name'..."
        curl -X POST -H "Content-Type: application/json" --data @"$file" "$CONNECT_URL"
        echo "Connector '$connector_name' created."
    fi
done

echo "All connectors have been processed."
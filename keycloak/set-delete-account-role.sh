#!/bin/bash

KEYCLOAK_URL="http://auth.devchat.localhost"
REALM="devchat"
ADMIN_USER="admin"
ADMIN_PASS="admin"
ADMIN_CLIENT="admin-cli"
DEFAULT_ROLE="default-roles-devchat"
DELETE_ACCOUNT_ROLE="delete-account"

TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=$ADMIN_CLIENT" \
  -d "username=$ADMIN_USER" \
  -d "password=$ADMIN_PASS" | jq -r '.access_token')

echo "Access token obtained: $TOKEN"

ACCOUNT_CLIENT_ID=$(curl -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM/clients?clientId=account" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.[0].id')

echo "Account client ID: $ACCOUNT_CLIENT_ID"

ID_DELETE_ACCOUNT=$(curl -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM/clients/$ACCOUNT_CLIENT_ID/roles/$DELETE_ACCOUNT_ROLE" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.id')

echo "Delete-account role ID: $ID_DELETE_ACCOUNT"

ID_DEFAULT_ROLE=$(curl -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM/roles/$DEFAULT_ROLE" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.id')

echo "Default role ID: $ID_DEFAULT_ROLE"

curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM/roles-by-id/$ID_DEFAULT_ROLE/composites" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "[{\"id\": \"$ID_DELETE_ACCOUNT\", \"name\": \"$DELETE_ACCOUNT_ROLE\"}]"

echo "Delete-account role added as a composite to the default role"
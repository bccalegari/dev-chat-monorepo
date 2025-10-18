.PHONY: all keycloak realm set-delete-account-role set-replica-identity kong kafka connectors create-connectors create-schemas help

keycloak-pre-setup:
	@echo "Starting Keycloak pre-setup tasks..."
	@echo "Ensuring generate-realm.sh is executable..."
	@chmod +x ./keycloak/generate-realm.sh
	@echo "Generating Realm JSON configuration..."
	@cd ./keycloak && ./generate-realm.sh
	@echo "Realm JSON configuration generated in keycloak/realm-export.json"
	@echo "Keycloak pre-setup tasks completed."

keycloak-post-setup:
	@echo "Starting Keycloak post-setup tasks..."
	@echo "Ensuring set-delete-account-role.sh is executable..."
	@chmod +x ./keycloak/set-delete-account-role.sh
	@echo "Setting delete-account role in Keycloak realm..."
	@cd ./keycloak && ./set-delete-account-role.sh
	@echo "delete-account role set in Keycloak realm."
	@echo "Ensuring set-replica-identity.sh is executable..."
	@chmod +x ./keycloak/set-replica-identity.sh
	@echo "Setting REPLICA IDENTITY FULL on Keycloak table..."
	@cd ./keycloak && ./set-replica-identity.sh
	@echo "REPLICA IDENTITY FULL set on Keycloak table."
	@echo "Keycloak post-setup tasks completed."

kong:
	@echo "Ensuring generate-kong-config.sh is executable..."
	@chmod +x ./kong/generate-kong-config.sh
	@echo "Generating Kong configuration YAML..."
	@cd ./kong && ./generate-kong-config.sh
	@echo "Kong configuration generated in kong/kong-config.yaml"

kafka-pre-setup:
	@echo "Starting Kafka pre-setup tasks..."
	@echo "Ensuring generate-connectors.sh is executable..."
	@chmod +x ./kafka-connect/generate-connectors.sh
	@echo "Generating Kafka Connect connectors..."
	@cd ./kafka-connect && ./generate-connectors.sh
	@echo "Kafka Connect connectors generated in kafka-connect/connectors/"
	@echo "After kafka connect is started, you can create the connectors using the create-connectors.sh script"
	@echo "Kafka pre-setup tasks completed."

kafka-post-setup:
	@echo "Starting Kafka post-setup tasks..."
	@echo "Ensuring create-connectors.sh is executable..."
	@chmod +x ./kafka-connect/create-connectors.sh
	@echo "Creating Kafka Connect connectors..."
	@cd ./kafka-connect && ./create-connectors.sh
	@echo "Kafka Connect connectors created."
	@echo "Ensuring create-schemas.sh is executable..."
	@chmod +x ./kafka-schema-registry/create-schemas.sh
	@echo "Creating schemas in Kafka Schema Registry..."
	@cd ./kafka-schema-registry && ./create-schemas.sh
	@echo "Schemas created in Kafka Schema Registry."
	@echo "Kafka post-setup tasks completed."

help:
	@echo "========================================"
	@echo "        devChat Makefile Help"        
	@echo "========================================"
	@echo
	@echo "All tasks:"
	@echo "----------------------------------------"
	@echo "Keycloak:"
	@echo "----------------------------------------"
	@echo "make keycloak-pre-setup        : Pre-setup tasks for Keycloak, including generating realm JSON"
	@echo "make keycloak-post-setup       : Post-setup tasks for Keycloak, including setting roles and replica identity"
	@echo
	@echo "Kong:"
	@echo "----------------------------------------"
	@echo "make kong                     : Generate Kong API Gateway YAML configuration file"
	@echo
	@echo "Kafka:"
	@echo "----------------------------------------"
	@echo "make kafka-pre-setup           : Pre-setup tasks for Kafka, including generating connector configs"
	@echo "make kafka-post-setup          : Post-setup tasks for Kafka, including creating connectors and schemas"
	@echo
	@echo "Tips:"
	@echo "----------------------------------------"
	@echo "Use 'make help' to show this message"
	@echo "Scripts are made executable automatically"
	@echo "========================================"

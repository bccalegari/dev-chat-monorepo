.PHONY: all realm kong connectors create-connectors help

SCRIPTS := generate-realm.sh generate-kong-config.sh

all: realm kong connectors
	@echo "All configuration files generated successfully!"

realm:
	@echo "Ensuring generate-realm.sh is executable..."
	@chmod +x ./keycloak/generate-realm.sh
	@echo "Generating Realm JSON configuration..."
	@cd ./keycloak && ./generate-realm.sh
	@echo "Realm JSON configuration generated in keycloak/realm-export.json"

kong:
	@echo "Ensuring generate-kong-config.sh is executable..."
	@chmod +x ./kong/generate-kong-config.sh
	@echo "Generating Kong configuration YAML..."
	@cd ./kong && ./generate-kong-config.sh
	@echo "Kong configuration generated in kong/kong-config.yaml"

connectors:
	@echo "Ensuring generate-connectors.sh is executable..."
	@chmod +x ./kafka-connect/generate-connectors.sh
	@echo "Generating Kafka Connect connectors..."
	@cd ./kafka-connect && ./generate-connectors.sh
	@echo "Kafka Connect connectors generated in kafka-connect/connectors/"
	@echo "After kafka connect is started, you can create the connectors using the create-connectors.sh script"

create-connectors:
	@echo "Ensuring create-connectors.sh is executable..."
	@chmod +x ./kafka-connect/create-connectors.sh
	@echo "Creating Kafka Connect connectors..."
	@cd ./kafka-connect && ./create-connectors.sh
	@echo "Kafka Connect connectors created."

help:
	@echo "Usage:"
	@echo "  make            		: Build all configuration files (Realm JSON, Kong YAML and Kafka Connect connectors)"
	@echo "  make realm      		: Generate the Keycloak Realm JSON configuration file"
	@echo "  make kong     	 		: Generate the Kong API Gateway YAML configuration file"
	@echo "  make connectors 	    : Generate Kafka Connect connectors for Keycloak"
	@echo "  make create-connectors : Create Kafka Connect connectors using the generated configurations"
	@echo "  make help       		: Display this help information"
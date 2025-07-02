.PHONY: all realm kong help

SCRIPTS := generate-realm.sh generate-kong-config.sh

all: realm kong
	@echo "All files generated."

realm:
	@echo "Ensuring generate-realm.sh is executable..."
	@chmod +x ./keycloak/generate-realm.sh
	@echo "Generating Realm JSON configuration..."
	@cd ./keycloak && ./generate-realm.sh

kong:
	@echo "Ensuring generate-kong-config.sh is executable..."
	@chmod +x ./kong/generate-kong-config.sh
	@echo "Generating Kong configuration YAML..."
	@cd ./kong && ./generate-kong-config.sh

help:
	@echo "Usage:"
	@echo "  make          : Build all configuration files (Realm JSON and Kong YAML)"
	@echo "  make realm    : Generate the Keycloak Realm JSON configuration file"
	@echo "  make kong     : Generate the Kong API Gateway YAML configuration file"
	@echo "  make help     : Display this help information"

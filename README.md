# Architecture Overview

## Envoy Proxy

Envoy acts as a reverse proxy to route incoming requests to the appropriate services based on domain names.

* Listens on port `80`.
* Routes requests to Keycloak, Kong, and Kafka Schema Registry depending on the requested host.
* Supports custom domains such as:

  * `auth.devchat.localhost`
  * `api.devchat.localhost`
  * `kafka-schema-registry.devchat.localhost`
* Enables centralized routing while preserving service separation.

## Kong API Gateway

Kong serves as the API Gateway, managing routing, authentication and other concerns for backend services.

* All client requests pass through Kong before reaching backend services.
* Integrates with Keycloak via the **dev-chat-kong-keycloak-jwt-verify** plugin for JWT validation.
* Offloads authentication logic from backend services.
* Ensures secure API access by verifying tokens before forwarding requests.

### dev-chat-kong-keycloak-jwt-verify

Custom Kong plugin for validating JWT tokens issued by Keycloak.

* Fetches public keys from Keycloak JWKS endpoint.
* Validates JWT signature and claims.
* Injects user information into request headers for upstream services.

For more details, see the repository: [dev-chat-kong-keycloak-jwt-verify](https://github.com/bccalegari/dev-chat-kong-keycloak-jwt-verify)

## Keycloak

Keycloak serves as the Identity Provider (IdP) for user authentication.

* Stores and manages all user information and credentials.
* Issues JWT access tokens for authenticated users.
* Provides JWKS endpoint for public keys used by Kong plugin.
* Acts as the source of truth for user identity (the domain "user" belongs to Keycloak).

### PostgreSQL Database
Keycloak uses a PostgreSQL database to persist user data and configurations.

## Kafka

Kafka is used for real-time data streaming and messaging between services.

### Kafka Connect

* Listens to Keycloak PostgreSQL database for changes in user records.
* Publishes user data events to Kafka topics in near real-time.
* Enables replication of user data to downstream services like **User Service**.
* Note: The canonical user data remains in Keycloak; Kafka is used only for replication and event propagation.

### Kafka Schema Registry

* Manages schemas for Kafka topics.
* Ensures consistent data structure across producers and consumers.

## User Service

The User Service manages the Profile and Friendship domains, handling user profiles and relationships within the application. It is built with **Node.js**, **TypeScript**, and **NestJS**, following a **hexagonal architecture** to separate business logic, infrastructure, and external integrations, ensuring scalability, maintainability, and testability.

* Provides operations for managing user profiles and friendships through a GraphQL API.  
* Listens to a Kafka topic replicated from Keycloak to synchronize user identity data in its own database, reducing the need for direct calls to Keycloak.  
* Persists user profiles and relationships in a Neo4j graph database, enabling efficient querying and management of social connections, such as discovering new friends.  
* Maintains a clear separation of responsibilities: authentication and identity are fully managed by Keycloak, while the service focuses exclusively on application-specific domain data.  
* Supports social features, including the creation and management of user profiles, friendships, and related operations.

### Neo4j Database

The User Service uses a Neo4j graph database to store and manage user profiles and relationships.

* Optimized for handling complex relationships and queries, such as exploring friends-of-friends or mutual connections.  
* Enables fast and efficient graph traversals, supporting social network features. 
* Allows flexible modeling of user data and relationships without rigid schema constraints.  
* Supports efficient queries for recommendations, social suggestions, and network analysis.  
* Simplifies the management of connected data, making it easier to scale social features as the application grows.

## WebApp (Frontend)

The WebApp is a client application built with React, Vite, and Tailwind CSS. It was developed using [Dyad](https://www.dyad.sh), a local open-source AI app builder, primarily to handle the visual and interactive aspects of the interface.

* Authenticates users via Keycloak using OAuth2/OpenID Connect.  
* Receives JWT access tokens from Keycloak and stores them securely in memory.  
* Sends requests to backend APIs through Kong, including the JWT in the `Authorization` header for authentication.  
* Fetches, updates, and manages user profile data through the User Service GraphQL API.  

# Setup Instructions

## Prerequisites

Before running, ensure you have the following installed:

* **Docker** and **Docker Compose**
* **make** (on Windows, use Git Bash or WSL; if using WSL, register custom hosts in WSL as well)
* **Git** to clone the repository
* **curl**, **jq** and **envsubst** command-line tools
  - **curl** for HTTP requests
  - **jq** for JSON processing
  - **envsubst** for configuration generation

## 1. Register Hosts

You need to register the custom domains from `/envoy/hosts.txt` to your system hosts file.

### Linux / Ubuntu

Edit the `/etc/hosts` file with `sudo`:

```bash
sudo nano /etc/hosts
```

Add the following lines:

```
127.0.0.1 auth.devchat.localhost
127.0.0.1 api.devchat.localhost
127.0.0.1 devchat.localhost
127.0.0.1 kafka-schema-registry.devchat.localhost
127.0.0.1 kafka-connect.devchat.localhost
```

Save and exit.

### Windows

Edit the file:

```
C:\Windows\System32\drivers\etc\hosts
```

Add the same lines above.

> Make sure to **run your terminal as Administrator** to be able to save the hosts file.

## 2. Environment Variables

Copy the example environment file and adjust variables as needed (e.g., SMTP settings for email functionality):

```bash
cp .env.local.sample .env
```

> If you don’t have an SMTP server for testing, email functionality can be disabled via the Keycloak UI.

## 3. Generate Configuration Files

All scripts are integrated into the **Makefile** for easier execution.

### Keycloak Configuration

Generate Keycloak configuration files:

```bash
make keycloak-pre-setup
```

* Generates the Keycloak realm configuration file: `keycloak/realm-export.json`
* Uses the template located at `./keycloak/realm-template.json`

### Kong Configuration

Generate Kong configuration:

```bash
make kong
```

* Generates `kong/kong-config.yaml` from `./kong/kong-template.yaml`

### Kafka Connectors Configuration

Generate Kafka Connectors configuration:

```bash
make kafka-pre-setup
```

* Generates connector JSON files in `./kafka-connect/connectors/`
* Templates located at `./kafka-connect/*-connector-template.json`

Example connectors generated:
* `keycloak-connector.json`

## 4. Start the Environment

Start all services using Docker Compose:

```bash
docker compose up
```

## 5. Post-Startup Setup

Some steps need to be executed after all services are running and healthy.

> Make sure to wait a few minutes for services to fully start before running these commands.

### Keycloak Post-Startup

Complete Keycloak setup:

```bash
make keycloak-post-setup
```

* Sets the `delete-account` role as default in the realm
* Configures `REPLICA IDENTITY FULL` on the Keycloak database table

### Kafka Post-Startup

Complete Kafka setup:

```bash
make kafka-post-setup
```

* Creates Kafka Connect connectors
* Creates schemas in Kafka Schema Registry

## 6. Makefile Overview

| Task                       | Purpose                                              |
| -------------------------- | ---------------------------------------------------- |
| `make keycloak-pre-setup`  | Generates Keycloak realm JSON configuration          |
| `make keycloak-post-setup` | Sets default roles and DB configuration for Keycloak |
| `make kong`                | Generates Kong YAML configuration                    |
| `make kafka-pre-setup`     | Generates Kafka Connectors configuration JSON        |
| `make kafka-post-setup`    | Creates Kafka Connectors and schemas                 |
| `make help`                | Shows detailed help for all Makefile commands        |

## 7. Quick Start Example

```bash
# 1. Register hosts
# Linux: sudo nano /etc/hosts
# Windows: edit C:\Windows\System32\drivers\etc\hosts as admin

# 2. Prepare Keycloak
make keycloak-pre-setup

# 3. Prepare Kong
make kong

# 4. Prepare Kafka
make kafka-pre-setup

# 5. Start all services
docker compose up

# 6. Wait a few minutes for services to be fully up and healthy

# 7. Post-setup tasks
make keycloak-post-setup
make kafka-post-setup
```
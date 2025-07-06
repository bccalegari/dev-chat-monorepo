FROM confluentinc/cp-kafka-connect:7.4.0

ENV DEBEZIUM_VERSION=2.6.0.Final

RUN curl -L -o /tmp/debezium-postgres.tar.gz https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/${DEBEZIUM_VERSION}/debezium-connector-postgres-${DEBEZIUM_VERSION}-plugin.tar.gz \
 && mkdir -p /usr/share/java/debezium-postgres \
 && tar -xzf /tmp/debezium-postgres.tar.gz -C /usr/share/java/debezium-postgres \
 && rm /tmp/debezium-postgres.tar.gz

RUN chown -R appuser:appuser /usr/share/java/debezium-postgres

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/java/debezium-postgres"
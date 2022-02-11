#!/bin/bash

echo "Installing Connector"

confluent-hub install --no-prompt debezium/debezium-connector-mysql:latest

confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:latest

confluent-hub install --no-prompt confluentinc/connect-transforms:latest

confluent-hub install --no-prompt confluentinc/kafka-connect-json-schema-converter:6.2.0

echo "Launching Kafka Connect worker"

/etc/confluent/docker/run &

sleep infinity
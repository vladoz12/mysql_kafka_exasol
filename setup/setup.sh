#!/bin/bash

curl -X PUT -H "Content-Type: application/vnd.schemaregistry.v1+json" --data '{"compatibility": "NONE"}' http://schema-registry:8081/config

pip install pyexasol==0.23.3

pip install pymysql==1.0.2

cd /resources/setup && python init_db_objects.py

curl -X POST -H "Content-Type: application/json"  kafka-connect:8083/connectors --data @/resources/connectors/mysql-source.json

curl -X POST -H "Content-Type: application/json"  kafka-connect:8083/connectors --data @/resources/connectors/exasol-sink.json

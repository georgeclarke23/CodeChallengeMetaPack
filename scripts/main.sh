#!/bin/sh

bash -c ' \
echo -e "\n\n=============\nWaiting for Kafka Connect to start listening on localhost ⏳\n=============\n"
while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) -ne 200 ] ; do
  echo -e "\t" $(date) " Kafka Connect listener HTTP state: " $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) " (waiting for 200)"
  sleep 5
done
echo -e $(date) "\n\n--------------\n\o/ Kafka Connect is ready! Listener HTTP state: " $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) "\n--------------\n"
'

curl -s localhost:8083/connector-plugins|jq '.[].class'

#make sure u start streaming data to the database

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @postgres-connector.json

# Apache Kafka >=2.3
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
       jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
       column -s : -t| sed 's/\"//g'| sort


#aws dynamodb list-tables --endpoint-url http://localhost:8000
#
#
#aws dynamodb create-table \
#    --table-name dynamodb-sink \
#    --attribute-definitions AttributeName=IncidentNumber,AttributeType=S AttributeName=IncidentGroup,AttributeType=S \
#    --key-schema AttributeName=IncidentNumber,KeyType=HASH AttributeName=IncidentGroup,KeyType=RANGE \
#    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
#    --endpoint-url http://localhost:8000


#curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/sink-dynamodb-incidents-00/config -d @connectors_config/dynamo-db-connector.json
##
### Apache Kafka >=2.3
#curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
#       jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
#       column -s : -t| sed 's/\"//g'| sort

docker exec kafkacat kafkacat \
        -b kafka:29092 \
        -r http://schema-registry:8081 \
        -s avro \
        -t dbserver1.public.incidents \
        -C -o -10 -q | jq '.after'

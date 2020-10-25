docker-compose up -d

bash -c ' \
echo -e "\n\n=============\nWaiting for Kafka Connect to start listening on localhost ⏳\n=============\n"
while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) -ne 200 ] ; do
  echo -e "\t" $(date) " Kafka Connect listener HTTP state: " $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) " (waiting for 200)"
  sleep 5
done
echo -e $(date) "\n\n--------------\n\o/ Kafka Connect is ready! Listener HTTP state: " $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) "\n--------------\n"
'


curl -i -X PUT -H  "Content-Type:application/json" \
    http://localhost:8083/connectors/source-debezium-incidents-00/config \
    -d '{
            "connector.class": "io.debezium.connector.mysql.MySqlConnector",
            "database.hostname": "mysql",
            "database.port": "3306",
            "database.user": "debezium",
            "database.password": "dbz",
            "database.server.id": "42",
            "database.server.name": "asgard",
            "table.whitelist": "demo.incidents",
            "database.history.kafka.bootstrap.servers": "kafka:29092",
            "database.history.kafka.topic": "dbhistory.demo" ,
            "decimal.handling.mode": "double",
            "include.schema.changes": "true",
            "transforms": "unwrap,addTopicPrefix",
            "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
            "transforms.addTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
            "transforms.addTopicPrefix.regex":"(.*)",
            "transforms.addTopicPrefix.replacement":"mysql-debezium-$1",
            "key":"IncidentNumber"
    }'

# Apache Kafka >=2.3
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
       jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
       column -s : -t| sed 's/\"//g'| sort



python3 main.py
# CodeChallengeMetaPack

### Tech
This project is based on a code challenge given by Metapack.

This project is dependent on:
- Kafka - Apache Kafka is an open-source stream-processing software platform developed by the Apache Software Foundation, written in Scala and Java. The project aims to provide a unified, high-throughput, low-latency platform for handling real-time data feeds

- Docker - Docker is a tool designed to make it easier to create, deploy, and run applications by using containers.
- Mysql - An RDBMS database and was required in the project brief.
- DynamoDB -  is a fully managed proprietary NoSQL database service that supports key-value and document data structures and is offered by Amazon

Note: The datasets had to be scaled down for storage purposes, you can replace the datasets with the complete datasets.

##  Challenges and Choices

- DynamoDB was the preferred over other NoSQL Engine, but DynamoDB has not GUI when your running locally in a container. This means the platform where you are running the container has to have awscli installed.

- Choose to use KSQL, to build streams because of its friendly SQL like interface. 

- I have pulled the docker container for an OS independent reliable deployment and all shell scripts are minimal to make the project transferrable to other OSs.


## Getting Started Running The Project
If you have docker and python  already installed in an environment, just clone the project and run the following command:

```bash
. ./buid_and_run.sh
``` 
#### or
You can  provision an EC2 instance that uses Ubuntu operating system, ssh into the EC2 instance and run the following commands: 
```bash
wget https://github.com/georgeclarke23/CodeChallengeMetaPack/archive/main.zip
sudo apt-get install unzip 
unzip main.zip
cd CodeChallengeMetaPack-main
. ./build_instance.sh
```

Once this is done, time to run the application in a container. SSH back into the EC2 instance and execute the following commands 
```bash
cd CodeChallengeMetaPack-main/

# This command will start the docker containers on the EC2 instance
. ./build_and_run.sh
```


## Query Kafka

Once all docker containers are up you can execute the following command to use the KSQL cli to query the data in kafka by creating streams.

```bash
docker exec -it ksqldb ksql http://localhost:8088
```

All queries are saved in `app/app.kqsl`

Note: I have intentionally allowed the server to run in interactive mode due to un-complete sink to No SQL data base.

## Other tools.

### Ingest data from a database
#### Look at the DB

Get a MySQL prompt
```shell script
docker exec -it mysql bash -c 'mysql -u root -p$MYSQL_ROOT_PASSWORD demo'
```
Look at new rows
```mysql-psql
SELECT * FROM INCIDENTS ORDER BY CREATE_TS DESC LIMIT 1\G
```

Automate view with new rows!
```shell script
watch -n 1 -x docker exec -t mysql bash -c 'echo "SELECT * FROM INCIDENTS ORDER BY CREATE_TS DESC LIMIT 1 \G" | mysql -u root -p$MYSQL_ROOT_PASSWORD demo'
```

### Connector Status

To check the status of source and sink connectors, you can execute this command

```shell script
# Apache Kafka >=2.3
curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
       jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
       column -s : -t| sed 's/\"//g'| sort
```

### View data in kafka topic

To view data that the source connector is sinking to kafka you can execute teh following command: 

```shell script
docker exec kafkacat kafkacat \
        -b kafka:29092 \
        -r http://schema-registry:8081 \
        -s avro \
        -t mysql-debezium-asgard.demo.INCIDENTS \
        -C -o -10 -q | jq '.IncidentStationGround.string, .CREATE_TS.string'
```
Note: This command can be used to view any topic by changing the value for the `-t ` option, `-s` option and `jq` option.
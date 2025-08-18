# .NET Application -> PostgreSQL -> Debezium -> Kafka -> SQL Server

This project demonstrates **real-time change data capture (CDC)** from **PostgreSQL** database into **Apache Kafka** using **Debezium**, with data flowing to **SQL Server** and a **.NET API** for database operations and **Kafka UI** for monitoring.

---

## What This Application Does

1. **PostgreSQL** stores customer data as the source database.
2. **Debezium Kafka Connect** monitors PostgreSQL for insert/update/delete events.
3. **Apache Kafka** receives these change events in real-time.
4. **SQL Server** receives the data from Kafka as the target database.
5. **.NET Application** can insert records in PostgreSQL.
6. **Kafka UI** lets you view Kafka topics/messages from your browser.

---

## Tech Stack

- **PostgreSQL** 15 (logical replication enabled)
- **SQL Server** 2022 (target database)
- **Zookeeper** (Kafka coordination)
- **Apache Kafka** 7.4.0
- **Debezium Connect** 2.7.3
- **Kafka UI** (Provectus)
- **ASP.NET Core** (.NET 9)
- **Docker Compose**

---

## Architecture

```
[.NET App] ---> [PostgreSQL] ---> [Debezium Connect] ---> [Kafka Broker] ---> [SQL Server]
      ^                                     |
      |                                     v
   API Calls                          [Kafka UI / Consumers]
```

---

## How to Run

### 1. Start all services
```bash
docker compose up -d 
```

**Services started:**

| Service         | Port | Description         |
|-----------------|------|---------------------|
| PostgreSQL      | 5432 | Source Database     |
| SQL Server      | 1433 | Target Database     |
| Zookeeper       | 2181 | Kafka coordination  |
| Kafka           | 9092 | Message broker      |
| Debezium Connect| 8083 | Kafka Connect API   |
| Kafka UI        | 9080 | Web interface       |
| .NET App        | 8080 | Sample API          |

---

### 2. Database Setup

#### PostgreSQL Setup
The PostgreSQL database is automatically configured with logical replication enabled.

#### SQL Server Setup
Wait for SQL Server to fully start, then enable CDC:

```bash
# Connect to SQL Server and enable CDC
docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "
EXEC sys.sp_cdc_enable_db;
USE customers_db;
EXEC sys.sp_cdc_enable_table 
    @source_schema = 'dbo', 
    @source_name = 'customers', 
    @role_name = NULL;
"
```

---

### 3. Register Debezium Connector

#### PostgreSQL Connector
```bash
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "postgres-connector",
    "config": {
      "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
      "tasks.max": "1",
      "plugin.name": "pgoutput",
      "database.hostname": "postgres",
      "database.port": "5432",
      "database.user": "postgres",
      "database.password": "postgres",
      "database.dbname": "customers_db",
      "database.server.name": "pgserver1",
      "table.include.list": "public.customers",
      "slot.name": "debezium_slot",
      "publication.name": "debezium_pub",
      "topic.prefix": "pg",
      "key.converter": "org.apache.kafka.connect.json.JsonConverter",
      "key.converter.schemas.enable": "false",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "false"
    }
  }'
```

#### SQLServer Connector
```bash
curl -X POST http://localhost:8083/connectors \
-H "Content-Type: application/json" \
-d '{
  "name": "sqlserver-sink-connector",
  "config": {
    "connector.class": "io.debezium.connector.jdbc.JdbcSinkConnector",
    "tasks.max": "1",
    "topics": "pg.public.Customers",
    "connection.url": "jdbc:sqlserver://sqlserver:1433;databaseName=customers_db;encrypt=true;trustServerCertificate=true;",
    "connection.username": "sa",
    "connection.password": "YourStrong!Passw0rd",
    "table.name.format": "customers",
    "schema.evolution": "basic",
    "auto.create": "true",
    "auto.evolve": "true",
    "insert.mode": "upsert",
    "primary.key.mode": "record_value",
    "primary.key.fields": "Id",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "true",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "true",
    "transforms": "unwrap",
    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "transforms.unwrap.drop.tombstones": "true",
    "transforms.unwrap.delete.handling.mode": "rewrite",
    "quote.identifiers": "true"
  }
}'
```


---

### 4. Verify Connector

#### Check connector status:
```bash
# List all connectors
curl -X GET http://localhost:8083/connectors

# Check PostgreSQL connector status
curl -X GET http://localhost:8083/connectors/postgres-connector/status


# Check SQLServer connector status
curl -X GET http://localhost:8083/connectors/sqlserver-sink-connector/status
```

#### Check Kafka topics:
```bash
# List all topics
curl -X GET http://localhost:8083/connector-plugins

# Or view in Kafka UI at http://localhost:9080
```

---


### 5. View Kafka Messages

** Kafka UI **
1. Open **http://localhost:8090**
2. Select topic: `pg.public.customers` (PostgreSQL changes)
3. View incoming messages in live mode.


---

## Troubleshooting

### Reset Connector
```bash
# Delete PostgreSQL connector
curl -X DELETE http://localhost:8083/connectors/postgres-connector

# Recreate using the curl command above
```

### View Connector Logs
```bash
# View Debezium Connect logs
docker logs connect

# View specific service logs
docker logs postgres
docker logs sqlserver
docker logs kafka
```

---

## Stop & Cleanup
```bash
docker-compose down
```

---

## Notes

### PostgreSQL
- Configured with `wal_level=logical`
- `max_replication_slots` and `max_wal_senders` increased
- Automatically creates replication slot and publication

### SQL Server
- CDC must be enabled manually after startup
- Uses SQL Server Agent for CDC (automatically started)
- Configured as target database to receive data from Kafka

### Kafka
- Auto-creates topics: `KAFKA_AUTO_CREATE_TOPICS_ENABLE=true`
- Topic created automatically: `pg.public.customers` (PostgreSQL changes)


---

### Expected Kafka Topic

After setting up the connector, you should see this topic in Kafka UI:

**pg.public.customers** - PostgreSQL customer changes

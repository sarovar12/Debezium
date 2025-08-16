# .NET Application -> PostgreSQL → Debezium → Kafka → Kafka UI

This project demonstrates **real-time change data capture (CDC)** from a PostgreSQL database into **Apache Kafka** using **Debezium**, with a **.NET API** for database operations and **Kafka UI** for topic inspection.

---

## What This Application Does

1. **PostgreSQL** stores customer data in `customers_db`.
2. **Debezium Kafka Connect** monitors the database for insert/update events via logical replication.
3. **Apache Kafka** receives these change events in real-time.
4. **.NET Application** inserts records in the database every 5 seconds.
5. **Kafka UI** lets you view Kafka topics/messages from your browser.

---

## 🛠 Tech Stack

- **PostgreSQL** 15 (logical replication enabled)
- **Zookeeper** (Kafka coordination)
- **Apache Kafka** 7.4.0
- **Debezium Connect** 2.7.3
- **Kafka UI** (Provectus)
- **ASP.NET Core** (.NET 9)
- **Docker Compose**

---

## 🗺 Architecture

```
[.NET App] ---> [PostgreSQL] ---> [Debezium Connect] ---> [Kafka Broker] ---> [Kafka UI / Consumers]
      ^                                                        |
      |                                                        v
   API Calls                                              Other systems
```

---

## 📂 Project Structure

```
.
├── docker-compose.yml   # All services
├── Dockerfile           # .NET app build
├── src/                 # .NET application code
└── README.md
```

---

## ▶️ How to Run

### 1️⃣ Start all services
```bash
docker compose up -d --build
```

**Services started:**

| Service         | Port  | Description         |
|-----------------|-------|---------------------|
| PostgreSQL      | 5432  | Database             |
| Zookeeper       | 2181  | Kafka coordination   |
| Kafka           | 9092  | Message broker       |
| Debezium Connect| 8083  | Kafka Connect API    |
| Kafka UI        | 8080  | Web interface        |
| .NET App        | 8081  | Sample API           |

---

### 2️⃣ Register the Debezium PostgreSQL Connector
```bash
curl -X POST http://localhost:8083/connectors   -H "Content-Type: application/json"   -d '{
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

---


### 3️⃣  View Kafka Messages

**Option 1 — Kafka UI (Recommended)**
1. Open **http://localhost:8080**
2. Select topic: `pg.public.customers`
3. View incoming messages in live mode.


## 🧹 Stop & Cleanup
```bash
docker compose down -v
```

---

## 📌 Notes
- PostgreSQL already has:
  - `wal_level=logical`
  - `max_replication_slots` and `max_wal_senders` increased
- Kafka is set to auto-create topics: `KAFKA_AUTO_CREATE_TOPICS_ENABLE=true`
- Debezium will automatically create the topic `pg.public.customers` when the connector is registered.

---


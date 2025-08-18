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
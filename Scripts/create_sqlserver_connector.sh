  curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "sqlserver-sink-connector",
    "config": {
      "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
      "tasks.max": "1",
      "topics": "pg.public.customers",
      "connection.url": "jdbc:sqlserver://sqlserver:1433;databaseName=customers_db;user=sa;password=YourStrong!Passw0rd",
      "table.name.format": "customers",
      "auto.create": "true",
      "insert.mode": "insert",
      "pk.mode": "none",
      "key.converter": "org.apache.kafka.connect.json.JsonConverter",
      "key.converter.schemas.enable": "false",
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": "false"
    }
  }'

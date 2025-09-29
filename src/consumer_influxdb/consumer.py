from kafka import KafkaConsumer
from influxdb_client_3 import InfluxDBClient3, Point
import json
import datetime
import os

# Setup Kafka
KAFKA_BROKER = "localhost:9092"  # ip broker on EC2
TOPIC = "stock_topic"

# Setup InfluxDB
host = "http://localhost:8181"
token = os.environ.get('INFLUXDB3_AUTH_TOKEN')
database = "stock_db"

# Create client infludb
client = InfluxDBClient3(host=host, token=token, database=database)

# Create consumer kafka
consumer = KafkaConsumer(
    TOPIC,
    bootstrap_servers=[KAFKA_BROKER],
    auto_offset_reset="earliest",   # from the beginning
    enable_auto_commit=True,
    group_id="stock-group",
    value_deserializer=lambda m: json.loads(m.decode("utf-8"))
)

print(f"Escuchando mensajes en el tópico {TOPIC}...")

for message in consumer:
    record = message.value

    # Example
    # {"Index": "NYA", "Date": "2025-09-11", "CloseUSD": 12345.67}

    index = record.get("Index")
    close_usd = float(record.get("CloseUSD"))
    date = record.get("Date")

    # Create point to InfluxDB
    point = (
        Point("stock_data")                # measurement
        .tag("Index", index)               # tag
        .field("CloseUSD", close_usd)      # value
        .time(datetime.datetime.utcnow())  # current timestamp
    )

    # Write to influxdb
    client.write(point, write_precision='s')

    print(f"Writing in InfluxDB: {index} - {date} - {close_usd}")

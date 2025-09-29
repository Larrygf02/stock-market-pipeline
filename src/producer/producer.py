from kafka import KafkaConsumer, KafkaProducer
import pandas as pd
import time
import json

producer = KafkaProducer(bootstrap_servers=['localhost:9092'],
                        value_serializer=lambda x:json.dumps(x).encode('utf-8'))

data = pd.read_csv('indexProcessed.csv')

selected_indices = ["NYA"]
data = data[data["Index"].isin(selected_indices)]

for _, row in data.iterrows():
    dict_stock = row.to_dict()
    producer.send('stock_topic', value=dict_stock)
    time.sleep(1)
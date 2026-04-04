import pika
import json
import time
from pymongo import MongoClient

mongo = MongoClient("mongodb://tarea_1_db:27017/")
db = mongo["futbol_db"]
coleccion = db["jugadores"]

while True:
    try:
        # Usamos 'guest' que es el default de tu imagen de RabbitMQ
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(host="tarea_1_rabbitmq")
        )
        break
    except Exception as e:
        print(f"Esperando a RabbitMQ... Error {e}")
        time.sleep(5)

channel = connection.channel()
channel.queue_declare(queue="jugadores_queue")  # El nombre de tu cola


def callback(ch, method, properties, body):
    data = json.loads(body)
    print(f" [📥] Recibido de Rabbit: {data}")
    # Aquí puedes decidir si insertas en Mongo o solo imprimes
    # coleccion.insert_one(data)


channel.basic_consume(
    queue="jugadores_queue", on_message_callback=callback, auto_ack=True
)

print(" [*] Tarea 1: Esperando mensajes en la cola. Para salir CTRL+C")
channel.start_consuming()

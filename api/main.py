from fastapi import FastAPI, HTTPException
from datetime import datetime
from pymongo import MongoClient
from pydantic import BaseModel, Field
from typing import List, Optional
from bson import ObjectId
import pika
import json
import os

app = FastAPI(title="Futbol API Completa")


@app.get("/health")
async def health():
    """Para health checks del ALB (debe responder 200)."""
    return {"status": "ok"}


# conexiones

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017/")
RABBIT_HOST = os.getenv("RABBIT_HOST", "localhost")

mongo_client = MongoClient(MONGO_URL)
db = mongo_client["futbol_db"]
collection = db["jugadores"]

def enviar_a_rabbit(mensaje):
    try:
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(host=RABBIT_HOST)
        )
        channel = connection.channel()
        channel.queue_declare(queue="jugadores_queue")
        channel.basic_publish(
            exchange="",
            routing_key="jugadores_queue",
            body=json.dumps(mensaje)
        )
        connection.close()
    except Exception as e:
        print(f"Error RabbitMQ: {e}")

# clase jugador
class JugadorSchema(BaseModel):
    nombre: str
    edad: int = Field(..., gt=0, lt=50)
    altura: float
    peso: float
    nacionalidad: str
    equipo_actual: str
    posicion: str
    equipos_anteriores: Optional[List[str]] = []


# endpoints


@app.get("/jugadores/")
async def listar_jugadores():
    jugadores = []
    for doc in collection.find():
        doc["_id"] = str(doc["_id"])
        jugadores.append(doc)
    return jugadores


@app.get("/jugadores/{id}")
async def obtener_jugador(id: str):
    jugador = collection.find_one({"_id": ObjectId(id)})
    if not jugador:
        raise HTTPException(status_code=404, detail="Jugador no encontrado")
    jugador["_id"] = str(jugador["_id"])
    return jugador


@app.post("/jugadores/", status_code=201)
async def crear_jugador(jugador: JugadorSchema):
    jugador_dict = jugador.model_dump()
    jugador_dict["fecha_creacion"] = datetime.utcnow().isoformat()
    resultado = collection.insert_one(jugador_dict)

    nuevo_id = str(resultado.inserted_id)
    enviar_a_rabbit({"accion": "CREAR", "id": nuevo_id, "nombre": jugador.nombre})
    return {"mensaje": "Creado", "id": nuevo_id}


@app.put("/jugadores/{id}")
async def actualizar_jugador(id: str, datos_nuevos: JugadorSchema):
    resultado = collection.update_one(
        {"_id": ObjectId(id)}, {"$set": datos_nuevos.model_dump()}
    )
    if resultado.matched_count == 0:
        raise HTTPException(status_code=404, detail="Jugador no encontrado")

    enviar_a_rabbit({"accion": "ACTUALIZAR", "id": id})
    return {"mensaje": "Jugador actualizado correctamente"}


@app.delete("/jugadores/{id}")
async def borrar_jugador(id: str):
    resultado = collection.delete_one({"_id": ObjectId(id)})
    if resultado.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Jugador no encontrado")

    enviar_a_rabbit({"accion": "ELIMINAR", "id": id})
    return {"mensaje": f"Jugador con ID {id} eliminado"}

# 🚀 Tarea 1: Arquitectura de Microservicios  
### FastAPI + MongoDB + RabbitMQ  

Este proyecto implementa un sistema de gestión de jugadores de fútbol utilizando una arquitectura desacoplada.

La API recibe los datos, los persiste en **MongoDB** y emite un evento a **RabbitMQ** para su procesamiento asíncrono mediante un consumidor independiente.

---

## 🏗️ Arquitectura del Sistema

- **API (FastAPI):**  
  Punto de entrada del sistema. Valida datos con Pydantic y actúa como productor de mensajes.

- **Base de Datos (MongoDB):**  
  Almacenamiento persistente de los registros de jugadores.

- **Message Broker (RabbitMQ):**  
  Gestiona la cola de mensajes `jugadores_queue`.

- **Consumidor (Worker):**  
  Script independiente que procesa los eventos en tiempo real.

---

## 🛠️ Requisitos Previos

- Docker  
- Docker Compose  
- Python 3.10+ (para ejecutar el consumidor localmente)  
- MongoDB Compass (opcional, para visualizar la base de datos)

---

## 🚦 Guía de Inicio Rápido

### 1️⃣ Levantar la infraestructura

Construir e iniciar los servicios:

```bash
docker-compose up -d --build
```

Los contenedores creados serán:

- `tarea_1_api`
- `tarea_1_db`
- `tarea_1_rabbitmq`

Verificar que estén activos:

```bash
docker ps
```

---

### 2️⃣ Ejecutar el Consumidor

En una nueva terminal:

```bash
python consumidor.py
```

---
## 🧪 Pruebas Unitarias

El proyecto incluye pruebas unitarias desarrolladas con **pytest** y **FastAPI TestClient** para validar el correcto funcionamiento de los endpoints del CRUD de jugadores.

### 📌 Endpoints probados

Las pruebas cubren las siguientes operaciones:

- ✅ **CREATE** → `POST /jugadores/`
- ✅ **READ** → `GET /jugadores/{id}`
- ✅ **UPDATE** → `PUT /jugadores/{id}`
- ✅ **DELETE** → `DELETE /jugadores/{id}`
- ✅ Manejo de errores → `404 Jugador no encontrado`

### 📂 Ubicación de las pruebas

Las pruebas se encuentran en:

```bash
tests/test_players.py 
```

### ▶️ Cómo Ejecutar las Pruebas

### 1️⃣ Levantar los contenedores

```bash
docker-compose up -d
```
### 2️⃣ Activar el entorno virtual
```bash
source .venv/bin/activate
```
### 3️⃣ Ejecutar pytest
```bash
PYTHONPATH=. pytest -v
```
---

## 🔍 Chequeo de Código Estático

Para garantizar la calidad, consistencia y buenas prácticas del código, se utilizó **Ruff**, una herramienta moderna y rápida para análisis estático en Python.

Ruff permite detectar:

- Errores de sintaxis
- Imports no utilizados
- Variables definidas pero no usadas
- Problemas de estilo (PEP8)
- Código potencialmente problemático

### 🛠 Herramienta utilizada

Se utilizó **Ruff** como linter principal del proyecto.

### 📦 Instalación

Si no está instalado, se puede instalar con:

```bash
pip install ruff
```
### ▶️ Cómo Ejecutar el análisis
### 1️⃣ Para verificar errores en el código:

```bash
ruff check .
```
### 2️⃣ Formatear el código automáticamente: 
```bash
ruff format .
```

## Probar la API (Swagger)

Accede a la documentación interactiva:

👉 http://localhost:8000/docs

Ejemplo de solicitud POST con `curl`:

```bash
curl -X 'POST' 'http://localhost:8000/jugadores/' \
-H 'Content-Type: application/json' \
-d '{
  "nombre": "Lionel Messi",
  "edad": 36,
  "nacionalidad": "Argentina",
  "equipo_actual": "Inter Miami",
  "posicion": "delantero"
}'
```

---

## 📊 Monitoreo y Verificación

| Servicio       | URL / Host                 | Credenciales |
|---------------|----------------------------|--------------|
| RabbitMQ UI   | http://localhost:15672     | guest / guest |
| MongoDB Local | mongodb://localhost:27017  | N/A |

Consultar MongoDB desde la terminal:

```bash
docker exec -it tarea_1_db mongosh --eval "db.getSiblingDB('futbol_db').jugadores.find()"
```

---

## 🧹 Mantenimiento y Limpieza

Detener contenedores:

```bash
docker-compose stop
```

Eliminar contenedores y redes:

```bash
docker-compose down
```

Eliminar todo (incluyendo datos de la base de datos):

```bash
docker-compose down -v
```

---

## 👨‍💻 Autor

**Martin Estrada y Juan Andrés Correa**  
Tarea 1 – Microservicios 2026
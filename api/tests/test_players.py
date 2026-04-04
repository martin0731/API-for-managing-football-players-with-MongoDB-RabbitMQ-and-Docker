from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

# Prueba POST
def test_create_player():
    response = client.post("/jugadores/", json={
        "nombre": "Lionel Messi",
        "edad": 36,
        "altura": 1.70,
        "peso": 72.0,
        "nacionalidad": "Argentina",
        "equipo_actual": "Inter Miami",
        "posicion": "Delantero",
        "equipos_anteriores": ["Barcelona", "PSG"]
    })

    assert response.status_code == 201
    data = response.json()
    assert "id" in data
    assert data["mensaje"] == "Creado"

# POST - GET
def test_create_and_get_player():
    create_response = client.post("/jugadores/", json={
        "nombre": "Cristiano Ronaldo",
        "edad": 38,
        "altura": 1.87,
        "peso": 83.0,
        "nacionalidad": "Portugal",
        "equipo_actual": "Al Nassr",
        "posicion": "Delantero",
        "equipos_anteriores": ["Manchester United", "Real Madrid", "Juventus"]
    })

    assert create_response.status_code == 201
    player_id = create_response.json()["id"]

    get_response = client.get(f"/jugadores/{player_id}")
    assert get_response.status_code == 200

    data = get_response.json()
    assert data["_id"] == player_id
    assert data["nombre"] == "Cristiano Ronaldo"
    assert data["edad"] == 38

# GET
def test_get_nonexistent_player():
    fake_id = "64b000000000000000000000" 

    response = client.get(f"/jugadores/{fake_id}")
    assert response.status_code == 404
    assert response.json()["detail"] == "Jugador no encontrado"

# POST - PUT - GET
def test_update_player():
    create_response = client.post("/jugadores/", json={
        "nombre": "Neymar Jr",
        "edad": 31,
        "altura": 1.75,
        "peso": 68.0,
        "nacionalidad": "Brasil",
        "equipo_actual": "Al Hilal",
        "posicion": "Delantero",
        "equipos_anteriores": ["Barcelona", "PSG"]
    })

    assert create_response.status_code == 201
    player_id = create_response.json()["id"]

    update_response = client.put(f"/jugadores/{player_id}", json={
        "nombre": "Neymar Jr",
        "edad": 32,  # cambié la edad 
        "altura": 1.75,
        "peso": 68.0,
        "nacionalidad": "Brasil",
        "equipo_actual": "Al Hilal",
        "posicion": "Delantero",
        "equipos_anteriores": ["Barcelona", "PSG"]
    })

    assert update_response.status_code == 200

    get_response = client.get(f"/jugadores/{player_id}")
    data = get_response.json()

    assert data["edad"] == 32

# POST - DELETE - GET
def test_delete_player():
    create_response = client.post("/jugadores/", json={
        "nombre": "Kylian Mbappé",
        "edad": 25,
        "altura": 1.78,
        "peso": 73.0,
        "nacionalidad": "Francia",
        "equipo_actual": "PSG",
        "posicion": "Delantero",
        "equipos_anteriores": ["Monaco"]
    })

    assert create_response.status_code == 201
    player_id = create_response.json()["id"]

    delete_response = client.delete(f"/jugadores/{player_id}")
    assert delete_response.status_code == 200

    get_response = client.get(f"/jugadores/{player_id}")
    assert get_response.status_code == 404
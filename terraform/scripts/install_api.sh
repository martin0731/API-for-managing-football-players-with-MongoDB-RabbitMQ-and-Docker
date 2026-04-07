#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/user-data-api.log) 2>&1

# 1. Instalación de herramientas
dnf install -y docker git aws-cli
curl -fsSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

systemctl enable --now docker
usermod -aG docker ec2-user

# 2. Clonar y Configurar
cd /home/ec2-user
git clone https://github.com/martin0731/API-for-managing-football-players-with-MongoDB-RabbitMQ-and-Docker.git app
cd app/docker

# 3. Obtener IPs desde AWS SSM (Esencial para tu arquitectura)
REGION="us-east-1"
# Reintentar obtener IPs (por si las otras instancias aún están encendiendo)
for i in {1..30}; do
  MONGO_IP=$(aws ssm get-parameter --name "/message-queue/dev/mongodb/private_ip" --region "$REGION" --query "Parameter.Value" --output text 2>/dev/null || echo "None")
  RABBIT_IP=$(aws ssm get-parameter --name "/message-queue/dev/rabbitmq/private_ip" --region "$REGION" --query "Parameter.Value" --output text 2>/dev/null || echo "None")
  [ "$MONGO_IP" != "None" ] && [ "$RABBIT_IP" != "None" ] && break
  sleep 10
done

# 4. Crear variables de entorno
echo "MONGO_URL=mongodb://admin:password123@${MONGO_IP}:27017/?authSource=admin" > .env
echo "RABBIT_HOST=$RABBIT_IP" >> .env

# 5. Levantar con el fix de Buildkit (NO QUITAR ESTO)
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0
docker-compose up -d --build api

# 6. Verificación de salud
echo "Esperando que la API responda..."
until curl -sf "http://localhost:8000/health"; do sleep 10; done
echo "¡Despliegue exitoso!"
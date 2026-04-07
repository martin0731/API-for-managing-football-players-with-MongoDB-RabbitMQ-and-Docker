#!/bin/bash

dnf update -y
dnf install -y docker git aws-cli

# Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

cd /home/ec2-user

# Clonar repo
git clone https://github.com/martin0731/API-for-managing-football-players-with-MongoDB-RabbitMQ-and-Docker.git app
cd app/docker

# OBTENER RABBIT DESDE PARAMETER STORE
RABBIT_IP=$(aws ssm get-parameter \
  --name "/message-queue/dev/rabbitmq/public_ip" \
  --query "Parameter.Value" \
  --output text)

# EXPORTAR VARIABLE
export RABBIT_HOST="$RABBIT_IP"

# Levantar worker
docker-compose up -d worker